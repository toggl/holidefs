defmodule Holidefs.Definition do
  @moduledoc """
  A definition is a set of rules for the holiday events in
  the year.
  """

  @holidays_deps_path Path.join(Mix.Project.deps_path(), "holidays")

  alias Holidefs.Definition
  alias Holidefs.Definition.Rule

  require Logger

  defstruct [:code, :name, rules: []]

  @type t :: %Definition{
          code: atom,
          name: String.t(),
          rules: [Holidefs.Definition.Rule.t()]
        }

  @doc """
  Returns the path for the given locale definition file.
  """
  @spec file_path(atom, atom) :: binary
  def file_path(code, path_type \\ :default), do: Path.join(path(path_type), "#{code}.yaml")

  @doc """
  Returns the path where all the locale definitions are saved.
  """
  @spec path(atom) :: Path.t()
  def path(type \\ :default)

  def path(:default) do
    Path.join(:code.priv_dir(:holidefs), "/calendars/definitions")
  end

  def path(:deps) do
    @holidays_deps_path
  end

  @doc """
  Loads the definition for a locale code and name.

  If the file does not exists, it returns `nil`.

  If any definition rule is invalid, a `RuntimeError` will be raised
  """
  @spec load!(atom, String.t(), atom) :: t | nil
  def load!(code, name, path_type \\ :default) do
    case read_file(code, path_type) do
      {:ok, file_data} ->
        rules =
          file_data
          |> Map.get("months")
          |> Enum.flat_map(fn {month, rules} ->
            for rule <- rules, do: Rule.build(code, month, rule)
          end)

        %Definition{
          code: code,
          name: name,
          rules: rules
        }

      {:error, _} ->
        Logger.warning("Definition file for #{code} not found.")
        nil
    end
  end

  defp read_file(code, path_type \\ :default) do
    code
    |> file_path(path_type)
    |> to_charlist()
    |> YamlElixir.read_from_file()
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
