defmodule ReleasePing.Mixfile do
  use Mix.Project

  def project do
    [
      app: :release_ping,
      version: "0.0.0-development",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ReleasePing.Application, []},
      extra_applications: [
        :logger,
        :inets,
        :runtime_tools,
        :eventstore,
        :ecto,
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:commanded, "~> 0.13"},
      {:commanded_eventstore_adapter, "~> 0.1"},
      {:commanded_ecto_projections, "~> 0.4"},
      {:ecto_enum, "~> 1.0"},
      {:tesla, "~> 0.7"},
      {:quantum, ">= 2.1.0-beta.1"},
      {:timex, "~> 3.1"},
      {:timber, "~> 2.5"},
      {:bypass, "~> 0.8", only: :test},
      {:ex_machina, "~> 2.0", only: :test},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:distillery, "~> 1.4", runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
    ]
  end
end
