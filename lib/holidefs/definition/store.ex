defmodule Holidefs.Definition.Store do
  @moduledoc """
  This module loads and stores all the holiday definitions.
  """

  alias Holidefs.Definition

  @definitions for {c, n} <- Holidefs.locales(), do: Definition.load!(c, n)
  @locale_keys Holidefs.locales() |> Map.keys() |> Enum.map(&Atom.to_string/1)

  @doc """
  Returns all the loaded definitions with their rules
  """
  @spec all_definitions :: [Holidefs.Definition.t()]
  def all_definitions, do: @definitions

  @doc """
  Returns the definitions for the given locale
  """
  @spec get_definition(Holidefs.locale_code()) :: Holidefs.Definition.t() | nil
  def get_definition(l), do: Enum.find(@definitions, &(&1.code == get_locale_atom(l)))

  defp get_locale_atom(l) when l in @locale_keys, do: String.to_existing_atom(l)
  defp get_locale_atom(l) when is_binary(l) or is_atom(l), do: l
end
