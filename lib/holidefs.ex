defmodule Holidefs do
  @moduledoc """
  Holdefs is a holiday OTP application for multiple locales that loads the
  dates from definition files on the startup.
  """

  alias Holidefs.Definition
  alias Holidefs.Definition.Store
  alias Holidefs.Holiday
  alias Holidefs.Options

  @type error_reasons :: :no_def | :invalid_date

  @locales %{
    at: "Austria",
    au: "Australia",
    br: "Brazil",
    ca: "Canada",
    ch: "Switzerland",
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
    my: "Malaysia",
    nl: "Netherlands",
    no: "Norway",
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
    za: "South Africa"
  }

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
  Returns all the holidays for the given locale on the given date.

  If succeed returns a `{:ok, holidays}` tuple, otherwise
  returns a `{:error, reason}` tuple.
  """
  @spec on(atom, Date.t()) :: {:ok, [Holidefs.Holiday.t()]} | {:error, String.t()}
  @spec on(atom, Date.t(), Holidefs.Options.t()) ::
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
  @spec year(atom, integer) :: {:ok, [Holidefs.Holiday.t()]} | {:error, String.t()}
  @spec year(atom, integer, Holidefs.Options.t()) ::
          {:ok, [Holidefs.Holiday.t()]} | {:error, error_reasons}
  def year(locale, year, opts \\ []) do
    locale
    |> Store.get_definition()
    |> case do
      nil ->
        {:error, :no_def}

      %Definition{rules: rules, code: locale} when is_integer(year) ->
        {:ok, all_year_holidays(rules, year, locale, opts)}

      _ ->
        {:error, :invalid_date}
    end
  end

  @spec all_year_holidays(
          [Holidefs.Definition.Rule.t()],
          integer,
          atom,
          Holidefs.Options.t() | list
        ) :: [Holidefs.Holiday.t()]
  defp all_year_holidays(
         rules,
         year,
         locale,
         %Options{include_informal?: include_informal?} = opts
       ) do
    rules
    |> Stream.filter(&(include_informal? or not &1.informal?))
    |> Stream.flat_map(&Holiday.from_rule(locale, &1, year, opts))
    |> Enum.sort_by(&Date.to_erl(&1.date))
  end

  defp all_year_holidays(rules, year, locale, opts) when is_list(opts) or is_map(opts) do
    all_year_holidays(rules, year, locale, struct(Options, opts))
  end

  @doc """
  Returns all the holidays for the given locale between start
  and finish dates.

  If succeed returns a `{:ok, holidays}` tuple, otherwise
  returns a `{:error, reason}` tuple
  """
  @spec between(atom, Date.t(), Date.t(), Holidefs.Options.t()) ::
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
         %Definition{rules: rules, code: locale},
         %Date{} = start,
         %Date{} = finish,
         opts
       ) do
    holidays =
      start.year..finish.year
      |> Stream.flat_map(&all_year_holidays(rules, &1, locale, opts))
      |> Stream.drop_while(&(Date.compare(&1.date, start) == :lt))
      |> Enum.take_while(&(Date.compare(&1.date, finish) != :gt))

    {:ok, holidays}
  end

  defp find_between(_, _, _, _) do
    {:error, :invalid_date}
  end
end
