use Mix.Config

# General application configuration
config :release_ping,
  ecto_repos: [ReleasePing.Repo]

config :commanded_ecto_projections,
  repo: ReleasePing.Repo

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore

import_config "#{Mix.env}.exs"
