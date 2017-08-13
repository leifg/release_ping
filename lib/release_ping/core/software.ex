defmodule ReleasePing.Core.Software do
  use Ecto.Schema

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    website: String.t,
    licenses: [String.t]
  }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "software" do
    field :stream_version, :integer
    field :name, :string
    field :website, :string
    field :licenses, {:array, :string}

    timestamps()
  end
end
