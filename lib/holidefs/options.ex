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

  defstruct [:region, include_informal?: false, observed?: false]

  @type t ::
          Keyword.t()
          | map
          | %Holidefs.Options{
              region: String.t() | [String.t()],
              include_informal?: boolean,
              observed?: boolean
            }

  @doc """
  Returns the list of regions from the given `opts`.

  The `definition` will be used to get the all the regions and code.
  """
  @spec get_regions(Holidefs.Options.t, Holidefs.Definition.t()) :: [String.t()]
  def get_regions(opts, definition) do
    main_region = Atom.to_string(definition.code)
    case opts.region do
      [""] -> Definition.get_regions(definition)
      regions when is_list(regions) -> [main_region | regions]
      region when is_bitstring(region) -> [main_region, region]
      nil -> [main_region]
    end
  end
end
