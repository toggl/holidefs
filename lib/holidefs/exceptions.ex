defmodule Holidefs.Exceptions do
  @moduledoc false

  defmodule FunctionNotDefinedError do
    @moduledoc false
    defexception [:name]

    @impl Exception
    def message(exception) do
      "Function `#{exception.name}` is not defined."
    end
  end

  defmodule InvalidRuleMapError do
    @moduledoc false
    defexception [:map]

    @impl Exception
    def message(exception) do
      """
      Expected a rule map with one of these sets of keys:
       - `week` and `wday`
       - `mday`
       - `function`

      but got
      #{inspect(exception.map)}
      """
    end
  end
end
