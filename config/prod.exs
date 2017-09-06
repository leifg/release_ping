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
