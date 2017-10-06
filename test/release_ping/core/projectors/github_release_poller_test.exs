defmodule ReleasePing.Incoming.Projectors.GithubReleasePollerTest do
  alias ReleasePing.Core.Projectors.GithubReleasePoller
  alias ReleasePing.Core.Events.{ReleasePublished, SoftwareAdded}
  alias ReleasePing.Repo

  use ReleasePing.DataCase

  describe "GithubReleasePoller Read Model SoftwareAdded" do
    setup [:add_software]

    test "correctly creates an entry in the read model", %{github_release_poller: github_release_poller} do
      assert github_release_poller.repository == "erlang/otp"
    end
  end

  describe "GithubReleasePoller Read Model ReleasePublished" do
    setup [:add_software]

    test "correctly updates entry in the read model", %{github_release_poller: github_release_poller} do
      events = [
        %ReleasePublished{
          uuid: UUID.uuid4(),
          software_uuid: github_release_poller.software_uuid,
          version_string: "OTP-20.1",
          release_notes_url: "https://github.com/erlang/otp/releases/tag/OTP-20.1",
          published_at: "2017-09-26T14:45:43Z",
          seen_at: "2017-10-05T06:55:24.491401Z",
          github_cursor: "releases:Y3Vyc29yOnYyOpHOAHhy8Q==",
          pre_release: false,
        },
        %ReleasePublished{
          uuid: UUID.uuid4(),
          software_uuid: github_release_poller.software_uuid,
          version_string: "OTP-20.1.1",
          release_notes_url: "https://github.com/erlang/otp/releases/tag/OTP-20.1.1",
          published_at: "2017-10-02T13:55:35Z",
          seen_at: "2017-10-05T06:55:24.491401Z",
          github_cursor: "tags:MTAy",
          pre_release: false
        },
      ]

      events |> Enum.with_index() |> Enum.each(fn({event, index}) ->
        GithubReleasePoller.handle(event, %{stream_version: 1, event_number: 2 + index})
      end)

      github_release_poller = Repo.get_by(ReleasePing.Core.GithubReleasePoller, software_uuid: github_release_poller.software_uuid)

      assert github_release_poller.last_cursor_releases == "Y3Vyc29yOnYyOpHOAHhy8Q=="
      assert github_release_poller.last_cursor_tags == "MTAy"
    end
  end

  defp add_software(_context) do
    software_uuid = UUID.uuid4()

    event = %SoftwareAdded{
      uuid: software_uuid,
      name: "Elixir",
      type: "language",
      website: "https://erlang.org",
      github: "erlang/otp",
      licenses: ["Apache-2.0"],
      release_retrieval: "github_release_poller",
    }

    GithubReleasePoller.handle(event, %{stream_version: 1, event_number: 1})

    {:ok, %{github_release_poller: Repo.get_by(ReleasePing.Core.GithubReleasePoller, software_uuid: software_uuid)}}
  end
end
