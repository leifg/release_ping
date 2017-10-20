defmodule ReleasePing.Outgoing.Projectors.ActiveSubscription do
  use Commanded.Projections.Ecto, name: "Outgoing.Projectors.ActiveSubscription"
  use Timex


  alias ReleasePing.Outgoing.Events.SubscriptionActivated
  alias ReleasePing.Repo
  alias ReleasePing.Core.Software

  project %SubscriptionActivated{} = sub, %{stream_version: stream_version} do
    rows = sub.topics
      |> Enum.reduce([], fn(topic, acc) ->
        [type, slug] = String.split(topic, ":")

        software = case slug do
          "*" -> nil
          slug -> Repo.get_by(Software, slug: slug)
        end

        row = %{
          uuid: sub.uuid,
          stream_version: stream_version,
          name: sub.name,
          callback_url: sub.callback_url,
          priority: sub.priority,
          type: type,
          topic: slug,
          software_uuid: software.uuid,
        } |> Map.put(:inserted_at, Timex.now)
          |> Map.put(:updated_at, Timex.now)

        [row | acc]
      end)
    |> Enum.reverse()

    Ecto.Multi.insert_all(multi, :active_subscriptions, ReleasePing.Outgoing.ActiveSubscription, rows)
  end
end
