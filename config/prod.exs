use Mix.Config

config :release_ping, ReleasePing.Scheduler,
  jobs: [
    {"0 0,12 * * *", {ReleasePing.Scheduler, :poll_releases, []}}
  ]

config :eventstore, EventStore.Storage,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "${POSTGRES_USER}",
  password: "${POSTGRES_PASSWORD}",
  database: "eventstore",
  hostname: "${POSTGRES_HOST}",
  pool: DBConnection.Poolboy,
  pool_size: 10

config :release_ping, ReleasePing.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "${POSTGRES_USER}",
  password: "${POSTGRES_PASSWORD}",
  database: "release_ping_readstore",
  hostname: "${POSTGRES_HOST}",
  pool_size: 10

config :release_ping, ReleasePingWeb.Endpoint,
  http: [port: "${PORT}"],
  url: [host: "localhost", port: "${PORT}"],
  server: true,
  root: ".",
  version: Application.spec(:release_ping, :vsn)

# Do not print debug messages in production
config :logger, level: :info

import_config "prod.secret.exs"
