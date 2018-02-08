defmodule Holidefs.Mixfile do
  use Mix.Project

  def project do
    [
      app: :holidefs,
      version: "0.1.0",
      elixir: "~> 1.5",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:gettext] ++ Mix.compilers(),
      test_coverage: [tool: ExCoveralls],
      docs: docs(),
      preferred_cli_env: preferred_cli_env()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Holidefs.Application, []}
    ]
  end

  defp package do
    [
      name: :holidefs,
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Kelvin Stinghen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Teamweek/holidefs"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.8.10", only: [:test, :dev], optional: true, runtime: false},
      {:download, "~> 0.0.4", optional: true, runtime: false},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:excoveralls, "~> 0.6", only: :test},
      {:gettext, "~> 0.13"},
      {:yaml_elixir, "~> 1.3"}
    ]
  end
end
