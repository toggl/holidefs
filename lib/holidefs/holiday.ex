defmodule Holidefs.Holiday do
  @moduledoc """
  A holiday itself.
  """

  alias Holidefs.DateCalculator
  alias Holidefs.Definition.CustomFunctions
  alias Holidefs.Definition.Rule
  alias Holidefs.Holiday
  alias Holidefs.Options

  defstruct [:name, :raw_date, :observed_date, :date, :uid, informal?: false]

  @type t :: %Holidefs.Holiday{
          name: String.t(),
          raw_date: Date.t(),
          observed_date: Date.t(),
          date: Date.t(),
          informal?: boolean,
          uid: String.t()
        }

  @doc """
  Returns a list of holidays for the definition rule on the given year.
  """
  @spec from_rule(atom, Holidefs.Definition.Rule.t(), integer, Holidefs.Options.t()) :: [t]
  def from_rule(code, %Rule{year_ranges: year_ranges} = rule, year, opts \\ %Options{}) do
    if in_year_ranges?(List.wrap(year_ranges), year) do
      build_from_rule(code, rule, year, opts)
    else
      []
    end
  end

  defp in_year_ranges?([nil], _), do: true

  defp in_year_ranges?(list, year) when is_list(list),
    do: Enum.all?(list, &in_year_range?(&1, year))

  defp in_year_range?(%{"before" => before_year}, year), do: year <= before_year
  defp in_year_range?(%{"after" => after_year}, year), do: year >= after_year
  defp in_year_range?(%{"limited" => years}, year), do: year in years

  defp in_year_range?(%{"between" => %{"start" => year_start, "end" => year_end}}, year) do
    year in year_start..year_end
  end

  defp in_year_range?(%{"from" => from_year}, year), do: year >= from_year
  defp in_year_range?(%{"until" => until_year}, year), do: year <= until_year

  defp build_from_rule(code, %Rule{function: fun} = rule, year, opts) when fun != nil do
    name = translate_name(code, rule.name)

    case CustomFunctions.call(fun, year, rule) do
      list when is_list(list) ->
        for date <- list do
          %Holiday{
            name: name,
            raw_date: date,
            observed_date: load_observed(rule, date),
            date: load_date(rule, date, opts),
            informal?: rule.informal?,
            uid: generate_uid(code, year, rule.name)
          }
        end

      %Date{} = date ->
        [
          %Holiday{
            name: name,
            raw_date: date,
            observed_date: load_observed(rule, date),
            date: load_date(rule, date, opts),
            informal?: rule.informal?,
            uid: generate_uid(code, year, rule.name)
          }
        ]

      nil ->
        []
    end
  end

  defp build_from_rule(code, %Rule{month: month, day: day} = rule, year, opts)
       when nil not in [month, day] do
    {:ok, date} = Date.new(year, month, day)

    [
      %Holiday{
        name: translate_name(code, rule.name),
        raw_date: date,
        observed_date: load_observed(rule, date),
        date: load_date(rule, date, opts),
        informal?: rule.informal?,
        uid: generate_uid(code, year, rule.name)
      }
    ]
  end

  defp build_from_rule(code, %Rule{} = rule, year, opts) do
    date = DateCalculator.nth_day_of_week(year, rule.month, rule.week, rule.weekday)

    [
      %Holiday{
        name: translate_name(code, rule.name),
        raw_date: date,
        observed_date: load_observed(rule, date),
        date: load_date(rule, date, opts),
        informal?: rule.informal?,
        uid: generate_uid(code, year, rule.name)
      }
    ]
  end

  defp load_date(rule, date, %Options{observed?: observed?}) do
    load_date(rule, date, observed?)
  end

  defp load_date(rule, date, true) do
    load_observed(rule, date)
  end

  defp load_date(_rule, date, false) do
    date
  end

  defp load_observed(%Rule{observed: nil}, date), do: date
  defp load_observed(%Rule{observed: fun} = rule, date), do: CustomFunctions.call(fun, date, rule)

  defp generate_uid(code, year, name) do
    <<sha1::128, _::32>> = :crypto.hash(:sha, name)

    hash =
      <<sha1::128>>
      |> Base.encode16()
      |> String.downcase()

    "#{code}-#{year}-#{hash}"
  end

  @doc """
  Returns the translated name of the given holiday.
  """
  @spec translate_name(atom, String.t()) :: String.t()
  def translate_name(code, name) do
    Gettext.dgettext(Holidefs.Gettext, Atom.to_string(code), name)
  end
end
