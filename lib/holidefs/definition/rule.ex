defmodule Holidefs.Definition.Rule do
  @moduledoc """
  A definition rule has the information about the event and
  when it happens on a year.
  """

  require Logger

  alias Holidefs.Definition.CustomFunctions
  alias Holidefs.Definition.Rule
  alias Holidefs.Exceptions.{FunctionNotDefinedError, InvalidRuleMapError}

  defstruct [
    :name,
    :month,
    :day,
    :week,
    :weekday,
    :function,
    :function_modifier,
    :regions,
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
          function: atom | nil,
          function_modifier: integer | nil,
          regions: [String.t()],
          observed: atom | nil,
          year_ranges: map | nil,
          informal?: boolean
        }

  @valid_weeks [-5, -4, -3, -2, -1, 1, 2, 3, 4, 5]
  @valid_weekdays 1..7

  def build(code, month, %{"name" => name} = map) do
    %{
      "year_ranges" => year_ranges,
      "type" => type,
      "observed" => observed,
      "function" => function,
      "function_modifier" => function_modifier
    } = fill_missing(map)

    rule = %Rule{
      month: month,
      name: name,
      year_ranges: year_ranges,
      informal?: type == "informal",
      observed: observed_from_name(observed),
      regions: load_regions(map, code),
      function: function_from_name!(function),
      function_modifier: function_modifier
    }

    case map do
      %{"week" => week, "wday" => wday} ->
        %{rule | week: week!(week), weekday: weekday!(wday)}

      %{"mday" => mday} ->
        %{rule | day: mday}

      %{"function" => function} when not is_nil(function) ->
        rule

      _ ->
        raise InvalidRuleMapError, map: map
    end
  end

  defp fill_missing(map) do
    keys = ~w(year_ranges type observed function function_modifier)

    Enum.reduce(keys, map, fn key, map ->
      Map.put_new(map, key, nil)
    end)
  end

  defp load_regions(%{"regions" => regions}, code) do
    Enum.map(regions, &String.replace(&1, "#{code}_", ""))
  end

  defp load_regions(_, _) do
    []
  end

  defp observed_from_name(nil), do: nil
  defp observed_from_name(name), do: function_from_name!(name)

  @custom_functions :exports
                    |> CustomFunctions.module_info()
                    |> Keyword.keys()

  defp function_from_name!(name) when is_binary(name) do
    name
    |> String.replace(~r/\(.+\)/, "")
    |> String.to_atom()
    |> function_from_name!()
  end

  defp function_from_name!(:""), do: nil
  defp function_from_name!(nil), do: nil

  defp function_from_name!(name) when is_atom(name) and name in @custom_functions do
    name
  end

  defp function_from_name!(name) when is_atom(name) do
    raise FunctionNotDefinedError, name: name
  end

  def week!(week) when week in @valid_weeks, do: week
  def week!(nil), do: nil
  # Ruby uses 0 for Sunday, but Elixir uses 7
  def weekday!(0), do: weekday!(7)
  def weekday!(wday) when wday in @valid_weekdays, do: wday
  def weekday!(nil), do: nil
end
