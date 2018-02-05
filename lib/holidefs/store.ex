defmodule Holidefs.Store do
  @moduledoc """
  This module loads, stores and handles all the holidefs definitions.
  """

  use Agent

  alias Holidefs.Definition
  alias Holidefs.Event

  @doc """
  Starts the server and loads all calendar files
  """
  @spec start_link(nil) :: Agent.on_start()
  def start_link(nil) do
    Agent.start_link(&load_all/0, name: __MODULE__)
  end

  @doc """
  Returns the language to translate the keys to.
  """
  @spec get_language :: String.t()
  def get_language do
    Agent.get(__MODULE__, fn _ ->
      Gettext.get_locale(Holidefs.Gettext)
    end)
  end

  @doc """
  Sets the language to translate the keys to.

  To use the original descriptions, you can set the language to `"orig"`
  """
  @spec set_language(String.t()) :: nil
  def set_language(locale) do
    Agent.cast(__MODULE__, fn state ->
      Gettext.put_locale(Holidefs.Gettext, locale)
      state
    end)
  end

  @doc """
  Returns all the loaded definitions with their rules
  """
  @spec all_definitions :: [Holidefs.Definition.t()]
  def all_definitions do
    Agent.get(__MODULE__, &Map.fetch!(&1, :definitions))
  end

  @doc """
  Returns all the events for the given locale on the given date.

  If succeed returns a `{:ok, events}` tuple, otherwise
  returns a `{:error, reason}` tuple
  """
  @spec on(String.t(), Date.t()) :: {:ok, [Holidefs.Event.t()]} | {:error, String.t()}
  def on(locale, date, opts \\ []) do
    Agent.get(__MODULE__, fn state ->
      state
      |> get_definition(locale)
      |> find_between(date, date, locale, opts)
    end)
  end

  @doc """
  Returns all the events for the given year.

  If succeed returns a `{:ok, events}` tuple, otherwise
  returns a `{:error, reason}` tuple
  """
  @spec year(String.t(), integer) :: {:ok, [Holidefs.Event.t()]} | {:error, String.t()}
  def year(locale, year, opts \\ []) do
    Agent.get(__MODULE__, fn state ->
      state
      |> get_definition(locale)
      |> find_year(year, locale, opts)
    end)
  end

  @doc """
  Returns all the events for the given locale between start
  and finish dates.

  If succeed returns a `{:ok, events}` tuple, otherwise
  returns a `{:error, reason}` tuple
  """
  @spec between(String.t(), Date.t(), Date.t()) ::
          {:ok, [Holidefs.Event.t()]} | {:error, String.t()}
  def between(locale, start, finish, opts \\ []) do
    Agent.get(__MODULE__, fn state ->
      state
      |> get_definition(locale)
      |> find_between(start, finish, locale, opts)
    end)
  end

  defp get_definition(%{definitions: definitions}, locale) do
    Enum.find(definitions, &(&1.code == locale))
  end

  defp find_year(nil, _, _, _) do
    {:error, :no_def}
  end

  defp find_year(%Definition{rules: rules}, year, code, opts) do
    {:ok, all_year_events(rules, year, code, opts)}
  end

  defp all_year_events(rules, year, code, opts) do
    include_informal? = Keyword.get(opts, :include_informal?, false)

    rules
    |> Stream.filter(&(include_informal? or not &1.informal?))
    |> Stream.flat_map(&Event.from_rule(code, &1, year, opts))
    |> Enum.sort_by(&Date.to_erl(&1.date))
  end

  defp find_between(nil, _, _, _, _) do
    {:error, :no_def}
  end

  defp find_between(%Definition{rules: rules}, start, finish, code, opts) do
    events =
      start.year..finish.year
      |> Stream.flat_map(&all_year_events(rules, &1, code, opts))
      |> Stream.drop_while(&(Date.compare(&1.date, start) == :lt))
      |> Enum.take_while(&(Date.compare(&1.date, finish) != :gt))

    {:ok, events}
  end

  @locales %{
    "AT" => "Austria",
    "AU" => "Australia",
    "BR" => "Brazil",
    "CA" => "Canada",
    "CH" => "Switzerland",
    "CZ" => "Czech Republic",
    "DE" => "Germany",
    "DK" => "Denmark",
    "EE" => "Estonia",
    "ES" => "Spain",
    "FI" => "Finland",
    "FR" => "France",
    "GB" => "United Kingdom",
    # TODO - the Hong Kong file on office holidefs is coming with a
    # negative date
    # "HK" => "Hong Kong",
    "HR" => "Croatia",
    "HU" => "Hungary",
    "IE" => "Ireland",
    "IT" => "Italy",
    "MY" => "Malaysia",
    "NL" => "Netherlands",
    "NO" => "Norway",
    "PH" => "Philippines",
    "PL" => "Poland",
    "PT" => "Portugal",
    "RS_LA" => "Serbia (Latin)",
    "RU" => "Russia",
    "SE" => "Sweden",
    "SG" => "Singapore",
    "SI" => "Slovenia",
    "SK" => "Slovakia",
    "US" => "United States",
    "ZA" => "South Africa"
  }

  @doc """
  Returns a map of all the supported locales.

  The key is the code and the value the name of the locale.
  """
  @spec locales :: Map.t()
  def locales, do: @locales

  defp load_all do
    %{
      definitions: load_definitions()
    }
  end

  defp load_definitions do
    for {code, name} <- @locales, do: Definition.load!(code, name)
  end
end
