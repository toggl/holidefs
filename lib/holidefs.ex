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
  @spec set_language(Atom.t() | String.t()) :: nil
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
  @spec on(Atom.t(), Date.t()) :: {:ok, [Holidefs.Holiday.t()]} | {:error, String.t()}
  @spec on(Atom.t(), Date.t(), Holidefs.Options.t()) ::
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
  @spec year(Atom.t(), integer) :: {:ok, [Holidefs.Holiday.t()]} | {:error, String.t()}
  @spec year(Atom.t(), integer, Holidefs.Options.t()) ::
          {:ok, [Holidefs.Holiday.t()]} | {:error, error_reasons}
  def year(locale, year, opts \\ []) do
    locale
    |> Store.get_definition()
    |> find_year(year, opts)
  end

  @doc """
  Returns all the holidays for the given locale between start
  and finish dates.

  If succeed returns a `{:ok, holidays}` tuple, otherwise
  returns a `{:error, reason}` tuple
  """
  @spec between(Atom.t(), Date.t(), Date.t()) ::
          {:ok, [Holidefs.Holiday.t()]} | {:error, error_reasons}
  @spec between(Atom.t(), Date.t(), Date.t(), Holidefs.Options.t()) ::
          {:ok, [Holidefs.Holiday.t()]} | {:error, error_reasons}
  def between(locale, start, finish, opts \\ []) do
    locale
    |> Store.get_definition()
    |> find_between(start, finish, opts)
  end

  defp find_year(nil, _, _) do
    {:error, :no_def}
  end

  defp find_year(%Definition{rules: rules, code: locale}, year, opts) when is_integer(year) do
    {:ok, all_year_holidays(rules, year, locale, opts)}
  end

  defp find_year(_, _, _) do
    {:error, :invalid_date}
  end

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
