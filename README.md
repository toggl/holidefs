# Holidefs

Definition-based national holidays in Elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `holidefs` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:holidefs, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm).

## Definitions directory

As you might notice, the `priv/calendars/definitions` directory is empty when you
clone the project. This is because that folder is actually a git submodule for
another [git repository](https://github.com/holidefs/definitions), so to checkout
its content, you can execute the following commands:

```shell
git submodule init
git submodule update
```
