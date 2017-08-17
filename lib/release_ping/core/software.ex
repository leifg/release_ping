defmodule ReleasePing.Core.Software do
  use Ecto.Schema

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    website: String.t,
    github: String.t,
    licenses: [String.t],
    release_retrieval: String.t,
  }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "software" do
    field :stream_version, :integer
    field :latest_release_uuid, :binary_id
    field :name, :string
    field :website, :string
    field :github, :string
    field :licenses, {:array, :string}
    field :release_retrieval, :string

    timestamps()
  end
end
