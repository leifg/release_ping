defmodule ReleasePing.Worflows.PublishReleasesTest do
  alias ReleasePing.Worflows.PublishReleases
  alias ReleasePing.Incoming.Events.NewGithubReleasesFound
  alias ReleasePing.Fixtures.GithubResponses
  alias ReleasePing.Core
  alias ReleasePing.Core.Software
  alias ReleasePing.Core.Commands.PublishRelease

  use ExUnit.Case
  @pm_state %PublishReleases{}
  @seen_at "2017-09-02T16:19:42Z"

  @software_args %{
    name: "erlang",
    website: "http://www.erlang.org/",
    github: "erlang/otp",
    release_retrieval: :github_release_poller,
    licenses: ["Apache License 2.0"],
  }

  @event %NewGithubReleasesFound{
    uuid: "7601a9bd-bbaa-4999-a7fc-77aaae9130a0",
    github_uuid: "c2ab5347-1b80-4657-8bd4-6c4a55504a04",
    repo_owner: "erlang",
    repo_name: "otp",
    last_cursor_releases: GithubResponses.last_cursor_releases(),
    last_cursor_tags: GithubResponses.last_cursor_tags(),
    payload: [
      1 |> GithubResponses.new_releases_json() |> Poison.decode!,
      2 |> GithubResponses.new_releases_json() |> Poison.decode!,
    ],
  }

  describe "handle/2" do
    test "returns correct publish commands for new github releases" do
      {:ok, %Software{} = software} = Core.add_software(@software_args)
      software_uuid = software.uuid

      assert [
        %PublishRelease{
          software_uuid: ^software_uuid,
          version_string: "OTP-20.0-rc1",
          release_notes_url: "https://github.com/erlang/otp/releases/tag/OTP-20.0-rc1",
          published_at: "2017-05-31T15:43:09Z",
          seen_at: @seen_at,
          pre_release: true,
        },
        %PublishRelease{
          software_uuid: ^software_uuid,
          version_string: "OTP-20.0-rc2",
          release_notes_url: "https://github.com/erlang/otp/releases/tag/OTP-20.0-rc2",
          published_at: "2017-05-31T16:12:17Z",
          seen_at: @seen_at,
          pre_release: true,
        },
        %PublishRelease{
          software_uuid: ^software_uuid,
          version_string: "OTP-20.0",
          release_notes_url: "https://github.com/erlang/otp/releases/tag/OTP-20.0",
          published_at: "2017-06-21T12:21:02Z",
          seen_at: @seen_at,
          pre_release: false,
        },
        %PublishRelease{
          software_uuid: ^software_uuid,
          version_string: "OTP-20.0.1",
          release_notes_url: "https://github.com/erlang/otp/releases/tag/OTP-20.0.1",
          published_at: "2017-06-30T13:21:23Z",
          seen_at: @seen_at,
          pre_release: false,
        },
        %PublishRelease{
          software_uuid: ^software_uuid,
          version_string: "OTP-19.3.6.2",
          release_notes_url: "https://github.com/erlang/otp/releases/tag/OTP-19.3.6.2",
          published_at: "2017-07-25T07:47:11Z",
          seen_at: @seen_at,
          pre_release: false,
        },
        %PublishRelease{
          software_uuid: ^software_uuid,
          version_string: "OTP-20.0.2",
          release_notes_url: "https://github.com/erlang/otp/releases/tag/OTP-20.0.2",
          published_at: "2017-07-26T09:46:41Z",
          seen_at: @seen_at,
          pre_release: false,
        },
        %PublishRelease{
          software_uuid: ^software_uuid,
          version_string: "OTP-20.0.3",
          release_notes_url: "https://github.com/erlang/otp/releases/tag/OTP-20.0.3",
          published_at: "2017-08-23T08:39:52Z",
          seen_at: @seen_at,
          pre_release: false,
        },
        %PublishRelease{
          software_uuid: ^software_uuid,
          version_string: "OTP-20.0.4",
          release_notes_url: "https://github.com/erlang/otp/releases/tag/OTP-20.0.4",
          published_at: "2017-08-25T07:36:12Z",
          seen_at: @seen_at,
          pre_release: false,
        },
      ] = PublishReleases.handle(@pm_state, @event)
    end
  end
end
