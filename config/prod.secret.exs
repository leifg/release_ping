use Mix.Config

config :release_ping, ReleasePingWeb.Endpoint,
  secret_key_base: "${SECRET_KEY_BASE}"
