defmodule Holidefs do
  @moduledoc """
  Holidefs is a holiday OTP application for multiple locales that loads the
  dates from definition files on the startup.
  """

  alias Holidefs.Definition
  alias Holidefs.Definition.Store
  alias Holidefs.Holiday
  alias Holidefs.Options

  @type error_reasons :: :no_def | :invalid_date
  @type locale_code :: atom | binary

  @all_locales %{
    at: "Austria",
    au: "Australia",
    be: "Belgium",
    br: "Brazil",
    ca: "Canada",
    ch: "Switzerland",
    co: "Colombia",
    cy: "Cyprus",
    cz: "Czech Republic",
    de: "Germany",
    dk: "Denmark",
    ee: "Estonia",
    es: "Spain",
    fi: "Finland",
    fr: "France",
    gb: "United Kingdom",
    hr: "Croatia",
    hu: "Hungary",
    ie: "Ireland",
    it: "Italy",
    lt: "Lithuania",
    my: "Malaysia",
    mx: "Mexico",
    nl: "Netherlands",
    no: "Norway",
    nz: "New Zealand",
    ph: "Philippines",
    pl: "Poland",
    pt: "Portugal",
    rs: "Serbia",
    ru: "Russia",
    se: "Sweden",
    sg: "Singapore",
    si: "Slovenia",
    sk: "Slovakia",
    us: "United States",
    za: "South Africa",
    fed: "Federal Reserve"
  }

  @locale_keys Application.get_env(:holidefs, :locales, Map.keys(@all_locales))
  @locales Map.take(@all_locales, @locale_keys)

  @doc """
  Returns a map of all the supported locales.

  The key is the code and the value the name of the locale.
  """
  @spec locales :: map
  def locales, do: @locales

  @doc """
  Returns the language to translate the holiday names to.
  """
  @spec get_language :: String.t()
  def get_language do
    Gettext.get_locale(Holidefs.Gettext)
  end

  @doc """
  Sets the language to translate the holiday names to.

  To use the native language names, you can set the language to `:orig`
  """
  @spec set_language(atom | String.t()) :: nil
  def set_language(locale) when is_atom(locale) do
    locale
    |> Atom.to_string()
    |> set_language()
  end

  def set_language(locale) when is_binary(locale) do
    Gettext.put_locale(Holidefs.Gettext, locale)
  end

  @doc """
  Returns the list of regions from the given locale.

  If succeed returns a `{:ok, regions}` tuple, otherwise
  returns a `{:error, reason}` tuple.
  """
  @spec get_regions(locale_code) :: {:ok, [String.t()]} | {:error, error_reasons}
  def get_regions(locale) do
    case Store.get_definition(locale) do
      nil -> {:error, :no_def}
      definition -> {:ok, Definition.get_regions(definition)}
    end
  end

  @doc """
  Returns all the holidays for the given locale on the given date.

  If succeed returns a `{:ok, holidays}` tuple, otherwise
  returns a `{:error, reason}` tuple.
  """
  @spec on(locale_code, Date.t()) :: {:ok, [Holidefs.Holiday.t()]} | {:error, error_reasons}
  @spec on(locale_code, Date.t(), Holidefs.Options.attrs()) ::
          {:ok, [Holidefs.Holiday.t()]} | {:error, error_reasons}
  def on(locale, date, opts \\ []) do
    locale
    |> Store.get_definition()
    |> find_between(date, date, opts)
  end

  @doc """
  Returns all the holidays for the given year.

  If succeed returns a `{:ok, holidays}` tuple, otherwise
  returns a `{:error, reason}` tuple
  """
  @spec year(locale_code, integer) :: {:ok, [Holidefs.Holiday.t()]} | {:error, String.t()}
  @spec year(locale_code, integer, Holidefs.Options.attrs()) ::
          {:ok, [Holidefs.Holiday.t()]} | {:error, error_reasons}
  def year(locale, year, opts \\ [])

  def year(locale, year, opts) when is_integer(year) do
    locale
    |> Store.get_definition()
    |> case do
      nil ->
        {:error, :no_def}

      %Definition{} = definition ->
        {:ok, all_year_holidays(definition, year, opts)}
    end
  end

  def year(_, _, _) do
    {:error, :invalid_date}
  end

  @spec all_year_holidays(Holidefs.Definition.t(), integer, Holidefs.Options.attrs()) :: [
          Holidefs.Holiday.t()
        ]
  defp all_year_holidays(
         %Definition{code: code, rules: rules},
         year,
         %Options{include_informal?: include_informal?, regions: regions} = opts
       ) do
    rules
    |> Stream.filter(&(include_informal? or not &1.informal?))
    |> Stream.filter(&(regions -- &1.regions != regions))
    |> Stream.flat_map(&Holiday.from_rule(code, &1, year, opts))
    |> Enum.sort_by(&Date.to_erl(&1.date))
  end

  defp all_year_holidays(definition, year, opts) when is_list(opts) or is_map(opts) do
    all_year_holidays(definition, year, Options.build(opts, definition))
  end

  @doc """
  Returns all the holidays for the given locale between start
  and finish dates.

  If succeed returns a `{:ok, holidays}` tuple, otherwise
  returns a `{:error, reason}` tuple
  """
  @spec between(locale_code, Date.t(), Date.t(), Holidefs.Options.attrs()) ::
          {:ok, [Holidefs.Holiday.t()]} | {:error, error_reasons}
  def between(locale, start, finish, opts \\ []) do
    locale
    |> Store.get_definition()
    |> find_between(start, finish, opts)
  end

  defp find_between(nil, _, _, _) do
    {:error, :no_def}
  end

  defp find_between(
         definition,
         %Date{} = start,
         %Date{} = finish,
         opts
       ) do
    holidays =
      start.year..finish.year
      |> Stream.flat_map(&all_year_holidays(definition, &1, opts))
      |> Stream.drop_while(&(Date.compare(&1.date, start) == :lt))
      |> Enum.take_while(&(Date.compare(&1.date, finish) != :gt))

    {:ok, holidays}
  end

  defp find_between(_, _, _, _) do
    {:error, :invalid_date}
  end
end
