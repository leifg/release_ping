defmodule ReleasePing.Outgoing.ActiveSubscription do
  alias ReleasePing.Repo
  alias ReleasePing.Outgoing.ActiveSubscription
  import Ecto.Query, only: [from: 2]

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

  def by_uuid(uuid) do
    Repo.all(from s in ActiveSubscription, where: s.uuid == ^uuid)
  end

  def matching(software) do
    query = from s in ActiveSubscription,
      where: s.type == "language" and (s.topic == ^software.slug or s.topic == "*"),
      order_by: [asc: s.priority]

    Repo.all(query)
  end
end
