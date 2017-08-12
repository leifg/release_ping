defmodule ReleasePing.Core.Software do
  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "software" do
    field :stream_version, :integer
    field :name, :string
    field :website, :string
    field :licenses, {:array, :string}

    timestamps()
  end
end
