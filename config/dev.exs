use Mix.Config


config :eventstore, EventStore.Storage,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "release_ping",
  password: "release_ping",
  database: "eventstore_dev",
  hostname: "localhost",
  pool: DBConnection.Poolboy,
  pool_size: 10

config :release_ping, ReleasePing.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "release_ping",
  password: "release_ping",
  database: "release_ping_readstore_dev",
  hostname: "localhost",
  pool_size: 10

config :release_ping, ReleasePingWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []


config :logger, level: :debug
config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
