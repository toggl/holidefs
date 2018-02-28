defmodule Holidefs.Definition do
  @moduledoc """
  A definition is a set of rules for the holiday events in
  the year.
  """

  alias Holidefs.Definition
  alias Holidefs.Definition.Rule

  defstruct [:code, :name, rules: []]

  @type t :: %Definition{
          code: atom,
          name: String.t(),
          rules: [Holidefs.Definition.Rule.t()]
        }

  @doc """
  Returns the path for the given locale definition file
  """
  @spec file_path(atom, Path.t()) :: binary
  def file_path(code, path \\ path()), do: Path.join(path, "#{code}.yaml")

  @doc """
  Returns the path where all the locale definitions are saved
  """
  @spec path() :: Path.t()
  def path() do
    Path.join(:code.priv_dir(:holidefs), "/calendars/definitions")
  end

  @doc """
  Loads the definition for a locale code and name.

  If any definition rule is invalid, a `RuntimeError` will be raised
  """
  @spec load!(atom, String.t()) :: t
  def load!(code, name) do
    rules =
      code
      |> file_path()
      |> to_charlist()
      |> YamlElixir.read_from_file()
      |> Map.get("months")
      |> Enum.flat_map(fn {month, rules} ->
        for rule <- rules, do: Rule.build(code, month, rule)
      end)

    %Definition{
      code: code,
      name: name,
      rules: rules
    }
  end

  @doc """
  Returns the list of regions from the definition.
  """
  @spec get_regions(t) :: [String.t()]
  def get_regions(%Definition{} = definition) do
    definition
    |> Map.get(:rules)
    |> Stream.flat_map(&Map.get(&1, :regions))
    |> Stream.uniq()
    |> Enum.sort()
  end
end
