defmodule ReleasePing.Mixfile do
  use Mix.Project

  def project do
    [
      app: :release_ping,
      version: "0.0.0-development",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
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
        :ecto
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:cors_plug, "~> 1.4"},
      {:commanded, "~> 0.14"},
      {:commanded_eventstore_adapter, "~> 0.2"},
      {:commanded_ecto_projections, "~> 0.4"},
      {:ecto_enum, "~> 1.1"},
      {:tesla, "~> 0.7"},
      {:quantum, "~> 2.1"},
      {:timex, "~> 3.1"},
      {:timber, "~> 2.5"},
      {:vex, "~> 0.6"},
      {:bypass, "~> 0.8", only: :test},
      {:ex_machina, "~> 2.0", only: :test},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:distillery, "~> 1.4", runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false}
    ]
  end
end
