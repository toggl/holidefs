defmodule Holidefs.Mixfile do
  use Mix.Project

  def project do
    [
      app: :holidefs,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:gettext] ++ Mix.compilers()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Holidefs.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_ical, "~> 0.1.0"},
      {:gettext, "~> 0.13"},
      {:yaml_elixir, "~> 1.3"}
    ]
  end
end
