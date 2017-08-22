defmodule ReleasePing.Core.Release do
  use Ecto.Schema

  @type t :: %__MODULE__{
    uuid: String.t,
    version_string: String.t,
    software_uuid: String.t,
    major_version: non_neg_integer,
    minor_version: non_neg_integer,
    patch_version: non_neg_integer,
    pre_release: boolean,
    release_notes_url: String.t,
    published_at: DateTime.t,
  }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "releases" do
    field :stream_version, :integer
    field :version_string, :string
    field :software_uuid, :binary_id
    field :major_version, :integer
    field :minor_version, :integer
    field :patch_version, :integer
    field :pre_release, :boolean
    field :release_notes_url, :string
    field :published_at, :utc_datetime
    field :seen_at, :utc_datetime

    timestamps()
  end
end
