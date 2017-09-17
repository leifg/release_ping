use Mix.Config

config :release_ping, ReleasePing.Scheduler,
  jobs: [
    {"@daily", {ReleasePing.Scheduler, :poll_releases, []}}
  ]

config :eventstore, EventStore.Storage,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "${POSTGRES_USER}",
  password: "${POSTGRES_PASSWORD}",
  database: "eventstore",
  hostname: "${POSTGRES_HOST}",
  pool_size: 10

config :release_ping, ReleasePing.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "${POSTGRES_USER}",
  password: "${POSTGRES_PASSWORD}",
  database: "release_ping_readstore",
  hostname: "${POSTGRES_HOST}",
  pool_size: 10

config :release_ping, ReleasePingWeb.Endpoint,
  load_from_system_env: true,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

import_config "prod.secret.exs"
