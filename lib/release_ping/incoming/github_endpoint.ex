defmodule ReleasePing.Incoming.GithubEndpoint do
  use Ecto.Schema

  @type t :: %__MODULE__{
    uuid: String.t,
    stream_version: integer,
    rate_limit_total: non_neg_integer,
    rate_limit_remaining: non_neg_integer,
    rate_limit_reset: DateTime.t,
  }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "github_endpoints" do
    field :stream_version, :integer
    field :rate_limit_total, :integer
    field :rate_limit_remaining, :integer
    field :rate_limit_reset, :utc_datetime

    timestamps()
  end

end
