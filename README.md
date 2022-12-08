# Holidefs

[![Build Status](https://travis-ci.org/Teamweek/holidefs.svg?branch=master)](https://travis-ci.org/Teamweek/holidefs)
[![Module Version](https://img.shields.io/hexpm/v/holidefs.svg)](https://hex.pm/packages/holidefs)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/holidefs/)
[![Total Download](https://img.shields.io/hexpm/dt/holidefs.svg)](https://hex.pm/packages/holidefs)
[![License](https://img.shields.io/hexpm/l/holidefs.svg)](https://github.com/Teamweek/holidefs/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/Teamweek/holidefs.svg)](https://github.com/Teamweek/holidefs/commits/master)

Definition-based national holidays in Elixir.

## Installation

The package can be installed by adding `:holidefs` to your list
of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:holidefs, "~> 0.3"}
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

See [`Holidefs` doc](http://hexdocs.pm/holidefs/Holidefs.html) to the
complete list of functions.

Also, for all these functions you can give a list of options like
this:

```elixir
Holidefs.between(:br, ~D[2018-02-01], ~D[2018-04-03], include_informal?: true)
# => {:ok, [%Holidefs.Holiday{name: "Good Friday", ...}, ...]}
```

For the complete list of options and their meaning check
[`Holidefs.Options` doc](http://hexdocs.pm/holidefs/Holidefs.Options.html)

## Copyright and License

Copyright (c) 2022 Toggl

This software is released under the [MIT License](./LICENSE).
