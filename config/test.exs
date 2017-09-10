use Mix.Config

config :eventstore, EventStore.Storage,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "release_ping",
  password: "release_ping",
  database: "eventstore_test",
  hostname: "localhost",
  pool_size: 1

config :release_ping, ReleasePing.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "release_ping",
  password: "release_ping",
  database: "release_ping_readstore_test",
  hostname: "localhost",
  pool_size: 1

config :logger, level: :warn
