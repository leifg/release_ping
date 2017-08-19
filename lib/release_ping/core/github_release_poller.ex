defmodule ReleasePing.Core.GithubReleasePoller do
  use Ecto.Schema

  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    repository: String.t,
  }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "github_release_pollers" do
    field :stream_version, :integer
    field :software_uuid, :binary_id
    field :repository, :string

    timestamps()
  end
end
