defmodule ReleasePing.Worflows.PublishReleases do
  defstruct []

  alias ReleasePing.Incoming.Events.NewGithubReleasesFound
  alias ReleasePing.Core.Commands.PublishRelease
  alias ReleasePing.Incoming.Utils.GithubReleases

  use Commanded.ProcessManagers.ProcessManager,
    name: "publish_release_workflow",
    router: ReleasePing.Router

  def interested?(%NewGithubReleasesFound{github_uuid: github_uuid}), do: {:start, github_uuid}

  def handle(%__MODULE__{}, %NewGithubReleasesFound{} = found_event) do
    found_event.payloads
    |> GithubReleases.merge_tags_and_releases(found_event.repo_owner, found_event.repo_name)
    |> Enum.map(fn(r) ->
      %PublishRelease{
        uuid: UUID.uuid4(),
        software_uuid: found_event.software_uuid,
        version_string: r.version_string,
        release_notes_url: r.release_notes_url,
        github_cursor: r.github_cursor,
        published_at: r.published_at,
        seen_at: found_event.seen_at,
        pre_release: r.pre_release,
      }
    end)
  end

  def apply(%__MODULE__{} = state, _), do: state
end
