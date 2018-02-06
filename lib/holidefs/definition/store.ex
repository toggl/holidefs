defmodule Holidefs.Definition.Store do
  @moduledoc """
  This module loads and stores all the holiday definitions.
  """

  use Agent

  alias Holidefs.Definition

  @doc """
  Starts the server and loads all calendar files
  """
  @spec start_link(nil) :: Agent.on_start()
  def start_link(nil) do
    Agent.start_link(&load_all/0, name: __MODULE__)
  end

  @doc """
  Returns all the loaded definitions with their rules
  """
  @spec all_definitions :: [Holidefs.Definition.t()]
  def all_definitions do
    Agent.get(__MODULE__, &Map.fetch!(&1, :definitions))
  end

  @doc """
  Returns the definitions for the given locale
  """
  @spec get_definition(Atom.t()) :: Holidefs.Definition.t()
  def get_definition(locale) do
    Agent.get(__MODULE__, fn %{definitions: definitions} ->
      Enum.find(definitions, &(&1.code == locale))
    end)
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
      definitions:
        for {code, name} <- @locales do
          Definition.load!(code, name)
        end
    }
  end
end
