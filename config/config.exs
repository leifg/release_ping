use Mix.Config

# General application configuration
config :release_ping,
  ecto_repos: [ReleasePing.Repo]

config :commanded_ecto_projections,
  repo: ReleasePing.Repo

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore

config :logger, level: :info

import_config "#{Mix.env}.exs"

# Import Timber, structured logging
import_config "timber.exs"
