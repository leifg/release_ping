defmodule ReleasePing.Mixfile do
  use Mix.Project

  def project do
    [
      app: :release_ping,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :eventstore]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:commanded, "~> 0.13"},
      {:commanded_eventstore_adapter, "~> 0.1"},
      {:ex_machina, "~> 2.0", only: :test},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
    ]
  end
end
