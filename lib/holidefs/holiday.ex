defmodule Holidefs.Holiday do
  @moduledoc """
  A holiday itself.
  """

  alias Holidefs.DateCalculator
  alias Holidefs.Definition.Rule
  alias Holidefs.Holiday
  alias Holidefs.Options

  defstruct [:name, :raw_date, :observed_date, :date, informal?: false]

  @type t :: %Holiday{
          name: String.t(),
          raw_date: Date.t(),
          observed_date: Date.t(),
          date: Date.t(),
          informal?: boolean
        }

  @doc """
  Returns a list of holidays for the definition rule on the given year
  """
  @spec from_rule(Atom.t(), Holidefs.Definition.Rule.t(), integer) :: [t]
  @spec from_rule(Atom.t(), Holidefs.Definition.Rule.t(), integer, Holidefs.Options.t()) :: [t]
  def from_rule(code, rule, year, opts \\ [])

  def from_rule(code, %Rule{year_ranges: year_ranges} = rule, year, opts) do
    if in_year_ranges?(year_ranges, year) do
      build_from_rule(code, rule, year, opts)
    else
      []
    end
  end

  defp in_year_ranges?(nil, _) do
    true
  end

  defp in_year_ranges?(list, year) when is_list(list) do
    Enum.all?(list, &in_year_range?(&1, year))
  end

  defp in_year_range?(%{"before" => before_year}, year), do: year <= before_year
  defp in_year_range?(%{"after" => after_year}, year), do: year >= after_year
  defp in_year_range?(%{"limited" => years}, year), do: year in years
  defp in_year_range?(%{"between" => years}, year), do: year in years

  defp build_from_rule(
         code,
         %Rule{name: name, function: fun, informal?: informal?} = rule,
         year,
         opts
       )
       when is_function(fun) do
    name = translate_name(code, name)

    case fun.(year, rule) do
      list when is_list(list) ->
        for date <- list do
          %Holiday{
            name: name,
            raw_date: date,
            observed_date: load_observed(rule, date),
            date: load_date(rule, date, opts),
            informal?: informal?
          }
        end

      %Date{} = date ->
        [
          %Holiday{
            name: name,
            raw_date: date,
            observed_date: load_observed(rule, date),
            date: load_date(rule, date, opts),
            informal?: informal?
          }
        ]

      nil ->
        []
    end
  end

  defp build_from_rule(
         code,
         %Rule{name: name, month: month, day: day, informal?: informal?} = rule,
         year,
         opts
       )
       when nil not in [month, day] do
    {:ok, date} = Date.new(year, month, day)

    [
      %Holiday{
        name: translate_name(code, name),
        raw_date: date,
        observed_date: load_observed(rule, date),
        date: load_date(rule, date, opts),
        informal?: informal?
      }
    ]
  end

  defp build_from_rule(
         code,
         %Rule{
           name: name,
           month: month,
           week: week,
           weekday: weekday,
           informal?: informal?
         } = rule,
         year,
         opts
       ) do
    date = DateCalculator.nth_day_of_week(year, month, week, weekday)

    [
      %Holiday{
        name: translate_name(code, name),
        raw_date: date,
        observed_date: load_observed(rule, date),
        date: load_date(rule, date, opts),
        informal?: informal?
      }
    ]
  end

  defp load_date(rule, date, %Options{observed?: observed?}) do
    load_date(rule, date, observed?)
  end

  defp load_date(rule, date, opts) when is_list(opts) or is_map(opts) do
    load_date(rule, date, struct(Options, opts))
  end

  defp load_date(rule, date, true) do
    load_observed(rule, date)
  end

  defp load_date(_rule, date, false) do
    date
  end

  defp load_observed(%Rule{observed: nil}, date) do
    date
  end

  defp load_observed(%Rule{observed: fun} = rule, date) when is_function(fun) do
    fun.(date, rule)
  end

  @doc """
  Returns the translated name of the given holiday
  """
  @spec translate_name(Atom.t(), String.t()) :: String.t()
  def translate_name(code, name) do
    Gettext.dgettext(Holidefs.Gettext, Atom.to_string(code), name)
  end
end
