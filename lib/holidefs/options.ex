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

  defstruct [:region, include_informal?: false, observed?: false]

  @type t ::
          Keyword.t()
          | map
          | %Holidefs.Options{
              region: String.t(),
              include_informal?: boolean,
              observed?: boolean
            }
end
