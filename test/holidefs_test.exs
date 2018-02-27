defmodule HolidefsTest do
  use ExUnit.Case

  alias Holidefs.Definition
  alias Holidefs.Holiday

  doctest Holidefs

  test "regions/1 returns all the regions for the given locale" do
    assert Holidefs.regions("will_never_exist") == {:error, :no_def}
    assert Holidefs.regions("us") == {:ok, [
      "ak", "al", "ar", "az", "ca", "co", "ct", "dc", "de", "fl", "ga", "gu", "hi", "ia", "id",
      "il", "in", "ks", "ky", "la", "ma", "md", "me", "mi", "mn", "mo", "ms", "mt", "nc", "nd",
      "ne", "nh", "nj", "nm", "nv", "ny", "oh", "ok", "or", "pa", "pr", "ri", "sc", "sd", "tn",
      "tx", "us", "ut", "va", "vi", "vt", "wa", "wi", "wv", "wy"
    ]}
  end

  test "between/3 returns all the calendars between the given dates" do
    Holidefs.set_language("orig")
    assert {:ok, holidays} = Holidefs.between(:br, ~D[2017-11-03], ~D[2017-12-24])

    assert holidays == [
             %Holiday{
               date: ~D[2017-11-15],
               name: "Proclamação da República",
               observed_date: ~D[2017-11-15],
               raw_date: ~D[2017-11-15]
             }
           ]

    assert {:ok, ^holidays} = Holidefs.between("br", ~D[2017-11-03], ~D[2017-12-24])
  end

  require Logger

  test "all definition files tests match" do
    Holidefs.set_language("orig")

    warning_count =
      Holidefs.locales()
      |> Stream.map(&test_definition/1)
      |> Enum.sum()

    if warning_count > 0, do: Logger.warn("Warning count: #{warning_count}")
  end

  defp test_definition({code, _}) do
    code
    |> Definition.file_path()
    |> YamlElixir.read_from_file()
    |> Map.get("tests")
    |> Stream.flat_map(fn
      %{"given" => %{"date" => list} = given, "expect" => expect} when is_list(list) ->
        for date <- list, do: {given, date, expect}

      %{"given" => %{"date" => date} = given, "expect" => expect} ->
        [{given, date, expect}]
    end)
    |> Stream.map(fn {given, date, expect} ->
      matches? = definition_test_match?(code, date, given, expect)
      msg = definition_test_msg(code, given, date, expect)

      if no_holiday?(expect) do
        if matches? do
          :ok
        else
          Logger.warn(msg)
          :warning
        end
      else
        assert matches?, msg
        :ok
      end
    end)
    |> Enum.count(&(&1 == :warning))
  end

  defp no_holiday?(%{"holiday" => false}), do: true
  defp no_holiday?(_), do: false

  defp definition_test_msg(code, given, date, expect) do
    """
    Test on definition file for #{inspect(code)} did not match.

    Date: #{inspect(date)}
    Given: #{inspect(given)}
    Expectation failed: #{inspect(expect)}
    """
  end

  defp given_options(%{"options" => opts}, region, code) when is_list(opts) do
    opts
    |> Stream.map(&translate_option/1)
    |> Enum.filter(&(&1 != nil))
    |> Keyword.merge(given_options(nil, region, code))
  end

  defp given_options(%{"options" => opt}, region, code) do
    Keyword.merge([translate_option(opt)], given_options(nil, region, code))
  end

  defp given_options(_, region, code) do
    [region: String.replace(region, "#{code}_", "")]
  end

  defp translate_option("informal"), do: {:include_informal?, true}
  defp translate_option("observed"), do: {:observed?, true}
  defp translate_option(_), do: nil

  defp definition_test_match?(code, date, given, expect) when is_bitstring(date) do
    [year, month, day] =
      date
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)
    definition_test_match?(code, date, given, expect)
  end

  defp definition_test_match?(code, date, given, expect) do
    for region <- given["regions"] do
      {:ok, holidays} = Holidefs.on(code, date, given_options(given, region, code))

      if no_holiday?(expect) do
        holidays == []
      else
        expect["name"] in Enum.map(holidays, & &1.name)
      end
    end
  end
end
