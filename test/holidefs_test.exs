defmodule HolidefsTest do
  use ExUnit.Case

  alias Holidefs.Definition
  alias Holidefs.Holiday

  doctest Holidefs

  test "locales/0 returns all the locales loaded on compile time" do
    assert Holidefs.locales() == %{
             at: "Austria",
             au: "Australia",
             be: "Belgium",
             br: "Brazil",
             hr: "Croatia",
             us: "United States",
             ca: "Canada",
             ch: "Switzerland",
             co: "Colombia",
             cz: "Czech Republic",
             de: "Germany",
             dk: "Denmark",
             ee: "Estonia",
             es: "Spain",
             fi: "Finland",
             fr: "France",
             gb: "United Kingdom",
             hu: "Hungary",
             ie: "Ireland",
             it: "Italy",
             lt: "Lithuania",
             mx: "Mexico",
             my: "Malaysia",
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
             za: "South Africa"
           }
  end

  test "get_regions/1 returns all the regions for the given locale" do
    assert Holidefs.get_regions("will_never_exist") == {:error, :no_def}

    assert Holidefs.get_regions("us") ==
             {:ok,
              [
                "ak",
                "al",
                "ar",
                "az",
                "ca",
                "co",
                "ct",
                "dc",
                "de",
                "fl",
                "ga",
                "gu",
                "hi",
                "ia",
                "id",
                "il",
                "in",
                "ks",
                "ky",
                "la",
                "ma",
                "md",
                "me",
                "mi",
                "mn",
                "mo",
                "ms",
                "mt",
                "nc",
                "nd",
                "ne",
                "nh",
                "nj",
                "nm",
                "nv",
                "ny",
                "oh",
                "ok",
                "or",
                "pa",
                "pr",
                "ri",
                "sc",
                "sd",
                "tn",
                "tx",
                "us",
                "ut",
                "va",
                "vi",
                "vt",
                "wa",
                "wi",
                "wv",
                "wy"
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
               raw_date: ~D[2017-11-15],
               uid: "br-2017-0ab43ef846d8bacc8c4694ad94207d17"
             }
           ]

    assert {:ok, ^holidays} = Holidefs.between("br", ~D[2017-11-03], ~D[2017-12-24])
  end

  require Logger

  test "all definition files tests match" do
    Holidefs.set_language("orig")

    sum =
      Holidefs.locales()
      |> Stream.map(fn {code, _} -> test_definition(code) end)
      |> Enum.sum()

    assert sum == 0, "There were errors on definition tests. Total number of errors: #{sum}"
  end

  test "setting and getting language" do
    Holidefs.set_language("orig")
    assert Holidefs.get_language() == "orig"
  end

  test "setting as atom and getting language" do
    Holidefs.set_language(:orig)
    assert Holidefs.get_language() == "orig"
  end

  test "return error when asking for all holidays for given year without definition" do
    assert Holidefs.year("unkown", 2020) == {:error, :no_def}
  end

  defp test_definition(code) do
    {:ok, file_data} =
      code
      |> Definition.file_path()
      |> YamlElixir.read_from_file()

    count =
      file_data
      |> Map.get("tests")
      |> Stream.flat_map(&check_expectations(code, &1))
      |> Enum.count(&(!&1))

    if count > 0, do: Logger.error("Errors for #{code}: #{count}")

    count
  end

  defp given_options(%{"options" => opts}, regions, code) when is_list(opts) do
    opts
    |> Stream.map(&translate_option/1)
    |> Enum.filter(&(&1 != nil))
    |> Keyword.merge(given_options(nil, regions, code))
  end

  defp given_options(%{"options" => opt}, regions, code) do
    Keyword.merge([translate_option(opt)], given_options(nil, regions, code))
  end

  defp given_options(_, regions, code) do
    [regions: Enum.map(regions, &String.replace(&1, "#{code}_", ""))]
  end

  defp translate_option("informal"), do: {:include_informal?, true}
  defp translate_option("observed"), do: {:observed?, true}
  defp translate_option(_), do: nil

  defp get_dates(%{"date" => list}) when is_list(list), do: Enum.map(list, &parse_date/1)
  defp get_dates(%{"date" => date}) when is_bitstring(date), do: [parse_date(date)]

  defp parse_date(date) when is_bitstring(date) do
    [year, month, day] =
      date
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)
    date
  end

  defp check_expectations(code, %{"given" => given, "expect" => expect}) do
    for date <- get_dates(given) do
      {:ok, holidays} =
        Holidefs.on(code, date, given_options(given, Map.get(given, "regions", []), code))

      matches? = expectation_matches?(expect, holidays)

      unless matches? do
        Logger.error("""
        Test on definition file for #{inspect(code)} did not match.

        Date: #{inspect(date)}
        Given: #{inspect(given)}
        Expectation failed: #{inspect(expect)}
        Holidays: #{inspect(holidays)}
        """)
      end

      matches?
    end
  end

  defp expectation_matches?(%{"holiday" => false}, []), do: true
  defp expectation_matches?(%{"holiday" => false}, _), do: false
  defp expectation_matches?(%{"name" => name}, hld), do: name in Enum.map(hld, & &1.name)
end
