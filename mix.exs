defmodule Holidefs.Mixfile do
  use Mix.Project

  @github_url "https://github.com/toggl/holidefs"
  @version "0.4.0"

  def project do
    [
      app: :holidefs,
      version: @version,
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      docs: docs(),
      preferred_cli_env: preferred_cli_env(),
      dialyzer: dialyzer()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:dev), do: ["lib", "dev/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp package do
    [
      description: "Definition-based national holidays",
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Kelvin Stinghen", "Adrien Anselme"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github_url}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "CODE_OF_CONDUCT.md": [title: "Code of Conduct"],
        "CONTRIBUTING.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @github_url,
      source_ref: "#v{@version}",
      homepage_url: @github_url,
      formatters: ["html"],
      api_reference: false
    ]
  end

  defp preferred_cli_env do
    [
      muzak: :test,
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  defp dialyzer do
    [
      plt_apps: [
        :compiler,
        :elixir,
        :gettext,
        :kernel,
        :logger,
        :stdlib,
        :yamerl,
        :yaml_elixir,
        :mix,
        :download
      ],
      dialyzer: [plt_add_deps: :transitive]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.4", only: [:test, :dev], optional: true, runtime: false},
      {:download, "~> 0.0.4", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:muzak, "~> 1.1", only: :test},
      {:gettext, "~> 0.23"},
      {:inch_ex, only: :docs},
      {:yaml_elixir, "~> 2.0"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:holidays,
       github: "holidays/definitions",
       ref: "b2c3d6dda526245082a6bd93a6b438f1990f845b",
       app: false,
       compile: false,
       depth: 1}
    ]
  end
end
