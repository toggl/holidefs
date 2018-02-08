# Holidefs

[![Build Status](https://travis-ci.org/Teamweek/holidefs.svg?branch=master)](https://travis-ci.org/Teamweek/holidefs)
[![Inline docs](http://inch-ci.org/github/Teamweek/holidefs.svg)](http://inch-ci.org/github/Teamweek/holidefs)

Definition-based national holidays in Elixir.

[Online documentation](http://hexdocs.pm/holidefs)

## Installation

The package can be installed by adding `holidefs` to your list
of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:holidefs, "~> 0.1.0"}
  ]
end
```

## Usage

To get holidays from you country you can use the functions on
`Holidefs` module, like this:

```elixir
Holidefs.between(:br, ~D[2018-03-01], ~D[2018-04-01])
# => {:ok, [%Holidefs.Holiday{name: "Good Friday", ...}, ...]}
```

See [`Holidefs` doc](http://hexdocs.pm/holidefs/Holidefs) to the
complete list of functions.

Also, for all these functions you can give a list of options like
this:

```elixir
Holidefs.between(:br, ~D[2018-02-01], ~D[2018-04-03], include_informal?: true)
# => {:ok, [%Holidefs.Holiday{name: "Good Friday", ...}, ...]}
```

For the complete list of options and their meaning check
[`Holidefs.Options` doc](http://hexdocs.pm/holidefs/Holidefs.Options)
