use Mix.Config

config :eventstore, EventStore.Storage,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "release_ping",
  password: "release_ping",
  database: "eventstore_dev",
  hostname: "localhost",
  pool_size: 10

config :release_ping, ReleasePing.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "release_ping",
  password: "release_ping",
  database: "release_ping_readstore_dev",
  hostname: "localhost",
  pool_size: 10

config :logger, level: :debug
