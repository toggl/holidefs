defmodule Holidefs.Event do
  @moduledoc """
  A holiday event, in other words, the holiday on a given year.
  """

  alias Holidefs.DateCalculator
  alias Holidefs.DefinitionRule
  alias Holidefs.Event

  defstruct [:name, :raw_date, :observed_date, :date, informal?: false]

  @type t :: %Event{
          name: String.t(),
          raw_date: Date.t(),
          observed_date: Date.t(),
          date: Date.t(),
          informal?: boolean
        }

  @doc """
  Returns a list of events for the definition rule on the given year
  """
  @spec from_rule(String.t(), Holidefs.DefinitionRule.t(), integer) :: [t]
  @spec from_rule(String.t(), Holidefs.DefinitionRule.t(), integer, Keyword.t()) :: [t]
  def from_rule(code, rule, year, opts \\ [])

  def from_rule(code, %DefinitionRule{year_ranges: year_ranges} = rule, year, opts) do
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
         %DefinitionRule{name: name, function: fun, informal?: informal?} = rule,
         year,
         opts
       )
       when is_function(fun) do
    name = translate_name(code, name)

    case fun.(year, rule) do
      list when is_list(list) ->
        for date <- list do
          %Event{
            name: name,
            raw_date: date,
            observed_date: load_observed(rule, date),
            date: load_date(rule, date, opts),
            informal?: informal?
          }
        end

      %Date{} = date ->
        [
          %Event{
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
         %DefinitionRule{name: name, month: month, day: day, informal?: informal?} = rule,
         year,
         opts
       )
       when nil not in [month, day] do
    {:ok, date} = Date.new(year, month, day)

    [
      %Event{
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
         %DefinitionRule{
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
      %Event{
        name: translate_name(code, name),
        raw_date: date,
        observed_date: load_observed(rule, date),
        date: load_date(rule, date, opts),
        informal?: informal?
      }
    ]
  end

  defp load_date(rule, date, opts) when is_list(opts) do
    load_date(rule, date, Keyword.get(opts, :observed?, false))
  end

  defp load_date(rule, date, true) do
    load_observed(rule, date)
  end

  defp load_date(_rule, date, false) do
    date
  end

  defp load_observed(%DefinitionRule{observed: nil}, date), do: date

  defp load_observed(%DefinitionRule{observed: fun} = rule, date) when is_function(fun) do
    fun.(date, rule)
  end

  @doc """
  Returns the translated name of the given event
  """
  @spec translate_name(String.t(), String.t()) :: String.t()
  def translate_name(code, name) do
    Gettext.dgettext(Holidefs.Gettext, String.downcase(code), name)
  end

  @doc """
  Returns an event for the given fallback calendar event
  """
  @spec from_fallback(ExIcal.Event.t()) :: t
  def from_fallback(%ExIcal.Event{description: description, start: start}) do
    {:ok, date} = Date.new(start.year, start.month, start.day)
    %Event{name: description, date: date}
  end
end
