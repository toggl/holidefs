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

  To use the original descriptions, you can set the language to `:orig`
  """
  @spec set_language(Atom.t() | String.t()) :: nil
  def set_language(locale) when is_atom(locale) do
    locale
    |> Atom.to_string()
    |> set_language()
  end

  def set_language(locale) when is_binary(locale) do
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
  @spec on(Atom.t(), Date.t()) :: {:ok, [Holidefs.Event.t()]} | {:error, String.t()}
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
  @spec year(Atom.t(), integer) :: {:ok, [Holidefs.Event.t()]} | {:error, String.t()}
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
  @spec between(Atom.t(), Date.t(), Date.t()) ::
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

  defp find_year(%Definition{rules: rules}, year, locale, opts) do
    {:ok, all_year_events(rules, year, locale, opts)}
  end

  defp all_year_events(rules, year, locale, opts) do
    include_informal? = Keyword.get(opts, :include_informal?, false)

    rules
    |> Stream.filter(&(include_informal? or not &1.informal?))
    |> Stream.flat_map(&Event.from_rule(locale, &1, year, opts))
    |> Enum.sort_by(&Date.to_erl(&1.date))
  end

  defp find_between(nil, _, _, _, _) do
    {:error, :no_def}
  end

  defp find_between(%Definition{rules: rules}, start, finish, locale, opts) do
    events =
      start.year..finish.year
      |> Stream.flat_map(&all_year_events(rules, &1, locale, opts))
      |> Stream.drop_while(&(Date.compare(&1.date, start) == :lt))
      |> Enum.take_while(&(Date.compare(&1.date, finish) != :gt))

    {:ok, events}
  end

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
    # TODO - the Hong Kong file on office holidefs is coming with a
    # negative date
    # hk: "Hong Kong",
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
    rs_la: "Serbia (Latin)",
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
  @spec locales :: Map.t()
  def locales, do: @locales

  defp load_all do
    %{
      definitions: for {code, name} <- @locales do
        Definition.load!(code, name)
      end
    }
  end
end
