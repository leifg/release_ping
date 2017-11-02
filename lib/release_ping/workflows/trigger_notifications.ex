defmodule ReleasePing.Workflows.TriggerNotifications do
  alias ReleasePing.Core.Events.ReleasePublished
  alias ReleasePing.Outgoing.Commands.NotifySubscriber
  alias ReleasePing.Outgoing.ActiveSubscription

  defstruct []

  use Commanded.ProcessManagers.ProcessManager,
    name: "trigger_notifications_workflow",
    router: ReleasePing.Router

  def interested?(%ReleasePublished{software_uuid: software_uuid}), do: {:start, software_uuid}
  def handle(%__MODULE__{}, %ReleasePublished{} = published) do
    software = ReleasePing.Core.software_by_uuid(published.software_uuid)

    Enum.map(ActiveSubscription.matching(software), fn(subscription) ->
      %NotifySubscriber{
        uuid: UUID.uuid4(),
        release_uuid: published.uuid,
        subscription_uuid: subscription.uuid,
        session_uuid: UUID.uuid4(),
        payload: extract_payload(published, software)
      }
    end)
  end

  defp extract_payload(published, software) do
    %{
      uuid: published.uuid,
      software: %{
        uuid: software.uuid,
        name: software.name,
        slug: software.slug,
        type: :language,
      },
      version_string: published.version_string,
      display_version: published.display_version,
      version_info: transform_version_info(published.version_info),
      published_at: published.published_at,
      release_notes_url: published.release_notes_url,
    }
  end

  defp transform_version_info(version_info) do
    version_info |> Map.from_struct() |> Map.drop([:published_at])
  end
end
