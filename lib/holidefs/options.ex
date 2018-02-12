defmodule Holidefs.Options do
  @moduledoc """
  Here is the list of options you can send to `Holidefs` functions:

    * `include_informal?` - flag to include the informal holidays on the
    return list. Defaults to `false`
    * `observed?` - flag to consider the `observed_date` of the holidays as
    the `date`. Defaults to `false`

  """

  defstruct include_informal?: false, observed?: false

  @type t ::
          Keyword.t()
          | map
          | %Holidefs.Options{
              include_informal?: boolean,
              observed?: boolean
            }
end
