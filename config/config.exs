use Mix.Config


# General application configuration
config :release_ping,
  ecto_repos: [ReleasePing.Repo]

config :commanded_ecto_projections,
  repo: ReleasePing.Repo

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore

# Configures the endpoint
config :release_ping, ReleasePingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tEzzNYtrnMJcPcS14wEjlpYkT2J2hrzqvEfxJWLtny9NBEjqaMBh15djYVWUWnet",
  render_errors: [view: ReleasePingWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ReleasePing.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"

# Import Timber, structured logging
import_config "timber.exs"
