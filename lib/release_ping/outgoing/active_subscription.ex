defmodule ReleasePing.Outgoing.ActiveSubscription do
  use Ecto.Schema

  @type t :: %__MODULE__{
    uuid: String.t,
    stream_version: integer,
    name: String.t,
    callback_url: String.t,
    priority: integer,
    topic: String.t,
    type: ReleasePing.Core.Aggregates.Software.type,
    software_uuid: String.t,
  }

  @primary_key false

  schema "active_subscriptions" do
    field :uuid, :binary_id
    field :stream_version, :integer
    field :name, :string
    field :callback_url, :string
    field :priority, :integer
    field :topic, :string
    field :type, ReleasePing.Enums.SoftwareTypeEnum
    field :software_uuid, :binary_id

    timestamps()
  end
end
