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
  @spec get_definition(Holidefs.locale_code()) :: Holidefs.Definition.t() | nil
  def get_definition(locale) do
    Agent.get(__MODULE__, fn %{definitions: definitions} ->
      Enum.find(definitions, &(&1.code == get_locale_atom(locale)))
    end)
  end

  defp get_locale_atom(locale) when is_binary(locale) do
    if locale in locale_keys() do
      String.to_existing_atom(locale)
    else
      locale
    end
  end

  defp get_locale_atom(locale) when is_atom(locale) do
    locale
  end

  defp locale_keys do
    Holidefs.locales()
    |> Map.keys()
    |> Enum.map(&Atom.to_string/1)
  end

  defp load_all do
    %{
      definitions:
        for {code, name} <- Holidefs.locales() do
          Definition.load!(code, name)
        end
    }
  end
end
