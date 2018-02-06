defmodule Holidefs.Definition.Rule do
  @moduledoc """
  A definition rule has the information about the event and
  when it happens on a year.
  """

  alias Holidefs.Definition.CustomFunctions
  alias Holidefs.Definition.Rule

  defstruct [
    :name,
    :month,
    :day,
    :week,
    :weekday,
    :function,
    :observed,
    :year_ranges,
    informal?: false
  ]

  @type t :: %Rule{
          name: String.t(),
          month: integer,
          day: integer,
          week: integer,
          weekday: integer,
          function: function,
          observed: function,
          year_ranges: map,
          informal?: boolean
        }

  @valid_weeks [-5, -4, -3, -2, -1, 1, 2, 3, 4, 5]
  @valid_weekdays 1..7

  @doc """
  Builds a new rule from its month and definition map
  """
  @spec build(integer, Map.t()) :: {:ok, t} | {:error, :invalid_rule}
  def build(month, %{"name" => name, "function" => func} = map) do
    %Rule{
      name: name,
      month: month,
      day: map["mday"],
      week: map["week"],
      weekday: map["wday"],
      year_ranges: map["year_ranges"],
      informal?: map["type"] == "informal",
      observed: observed_from_name(map["observed"]),
      function:
        func
        |> function_from_name()
        |> load_function(map["function_modifier"])
    }
  end

  def build(month, %{"name" => name, "week" => week, "wday" => wday} = map)
      when week in @valid_weeks and wday in @valid_weekdays do
    %Rule{
      name: name,
      month: month,
      week: week,
      weekday: wday,
      year_ranges: map["year_ranges"],
      informal?: map["type"] == "informal",
      observed: observed_from_name(map["observed"])
    }
  end

  def build(month, %{"name" => name, "mday" => day} = map) do
    %Rule{
      name: name,
      month: month,
      day: day,
      year_ranges: map["year_ranges"],
      informal?: map["type"] == "informal",
      observed: observed_from_name(map["observed"])
    }
  end

  defp load_function(function, nil) do
    function
  end

  defp load_function(function, modifier) do
    fn year, rule ->
      case function.(year, rule) do
        %Date{} = date -> Date.add(date, modifier)
        other -> other
      end
    end
  end

  defp observed_from_name(nil), do: nil
  defp observed_from_name(name), do: function_from_name(name)

  @custom_functions :exports
                    |> CustomFunctions.module_info()
                    |> Keyword.keys()

  defp function_from_name(name) when is_binary(name) do
    name
    |> String.replace(~r/\(.+\)/, "")
    |> String.to_atom()
    |> function_from_name()
  end

  defp function_from_name(name) when is_atom(name) and name in @custom_functions do
    &apply(CustomFunctions, name, [&1, &2])
  end
end
