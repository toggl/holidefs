defmodule Holidefs.Definition.Store do
  @moduledoc """
  This module loads and stores all the holiday definitions.
  """

  alias Holidefs.Definition

  definitions = for {c, n} <- Holidefs.locales(), do: Definition.load!(c, n)

  @doc """
  Returns all the loaded definitions with their rules.
  """
  @spec all_definitions :: [Holidefs.Definition.t()]
  def all_definitions, do: unquote(Macro.escape(definitions))

  @doc """
  Returns the definitions for the given locale.
  """
  @spec get_definition(Holidefs.locale_code()) :: Holidefs.Definition.t() | nil
  for definition <- definitions do
    def get_definition(unquote(definition.code)), do: unquote(Macro.escape(definition))
    def get_definition(unquote(to_string(definition.code))), do: unquote(Macro.escape(definition))
  end

  def get_definition(_), do: nil
end
