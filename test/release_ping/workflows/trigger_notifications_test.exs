defmodule ReleasePing.Workflows.NotifySubscriberTest do
  alias ReleasePing.Outgoing.Commands.{NotifySubscriber, AddTrustedSubscription}
  alias ReleasePing.Outgoing.ActiveSubscription
  alias ReleasePing.Core.Events.ReleasePublished
  alias ReleasePing.Core.Version.VersionInfo
  alias ReleasePing.{Repo, Router, Wait}

  use ReleasePing.DataCase

  @pm_state %ReleasePing.Workflows.TriggerNotifications{}

  @event %ReleasePublished{
    uuid: "fef12aba-3ae4-4532-8790-c0ec3182719b",
    version_string: "v1.5.2",
    version_info: %VersionInfo{
      major: 1,
      minor: 5,
      patch: 2,
      pre_release: nil,
    },
    release_notes_url: "https://github.com/elixir-lang/elixir/releases/tag/v1.5.2",
    display_version: "1.5.2",
    published_at: "2017-09-29T12:10:47Z",
    seen_at: "2017-09-29T13:10:47Z",
    github_cursor: "releases:Y3Vyc29yOnYyOpHOAHhy8Q==",
    pre_release: false,
  }

  describe "handle/2" do
    test "returns correct notification command for new releases" do
      software = add_software()
      subscription = add_subscription()

      commands = ReleasePing.Workflows.TriggerNotifications.handle(@pm_state, Map.put(@event, :software_uuid, software.uuid))
      expected_command = %NotifySubscriber{
        subscription_uuid: subscription.uuid,
        release_uuid: @event.uuid,
        attempt: 1,
        payload: %{
          uuid: @event.uuid,
          software: %{
            uuid: software.uuid,
            type: :language,
            slug: "elixir",
            name: "elixir"
          },
          version_string: "v1.5.2",
          display_version: "1.5.2",
          published_at: "2017-09-29T12:10:47Z",
          release_notes_url: "https://github.com/elixir-lang/elixir/releases/tag/v1.5.2",
          version_info: %{
            major: 1,
            minor: 5,
            patch: 2,
            pre_release: nil,
          }
        }
      }

      [command] = commands

      assert command.uuid != nil
      assert command.session_uuid != nil

      assert normalize_command(command) == expected_command
    end
  end

  defp normalize_command(command) do
    command |> Map.put(:uuid, nil) |> Map.put(:session_uuid, nil)
  end

  defp add_software do
    {:ok, software} = ReleasePing.Core.add_software(build(:elixir))
    software
  end

  defp add_subscription do
    uuid = UUID.uuid4()

    command = %AddTrustedSubscription{
      uuid: uuid,
      name: "Test Subscription",
      callback_url: "https://leifg.ngrok.io",
      secret: "AtA6b2htZzp2IrgZ5so9",
      topics: ["language:elixir"],
      priority: 0,
    }

    Router.dispatch(command)

    {:ok, subscription} = Wait.until(fn ->
      case ActiveSubscription.by_uuid(uuid) do
        [] -> nil
        [sub] -> sub
      end
    end)

    subscription
  end
end
