defmodule Holidefs.Options do
  @moduledoc """
  Here is the list of options you can send to `Holidefs` functions:

    * `region` - a string to define what region will be loaded. When `nil`
    it fallbacks to the basic region of the locale, which is the region
    with the same code of the locale. Defaults to `nil`
    * `include_informal?` - flag to include the informal holidays on the
    return list. Defaults to `false`
    * `observed?` - flag to consider the `observed_date` of the holidays as
    the `date`. Defaults to `false`

  """

  alias Holidefs.Definition
  alias Holidefs.Options

  defstruct regions: [], include_informal?: false, observed?: false

  @type attrs :: Keyword.t() | map
  @type t :: %Options{
          regions: [String.t()],
          include_informal?: boolean,
          observed?: boolean
        }

  @doc """
  Builds a new `Options` struct with normalized fields.

  The `definition` is used to get the all the regions and code.
  """
  @spec build(attrs, Definition.t()) :: Options.t()
  def build(attrs, %Definition{} = definition) do
    opts = struct(Options, attrs)
    %{opts | regions: get_regions(opts.regions, definition)}
  end

  defp get_regions([""], definition) do
    Definition.get_regions(definition)
  end

  defp get_regions(regions, definition) when is_list(regions) do
    [main_region(definition) | regions]
  end

  defp get_regions(region, definition) when is_bitstring(region) do
    [main_region(definition), region]
  end

  defp get_regions(nil, definition) do
    [main_region(definition)]
  end

  defp main_region(%Definition{code: code}), do: Atom.to_string(code)
end
