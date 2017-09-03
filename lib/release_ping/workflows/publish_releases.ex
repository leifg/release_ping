defmodule ReleasePing.Worflows.PublishReleases do
  defstruct []

  alias ReleasePing.Core

  alias ReleasePing.Incoming.Events.NewGithubReleasesFound
  alias ReleasePing.Core.Commands.PublishRelease
  alias ReleasePing.Incoming.Utils.GithubReleases

  use Commanded.ProcessManagers.ProcessManager,
    name: "publish_release_workflow",
    router: ReleasePing.Router

  def interested?(%NewGithubReleasesFound{github_uuid: github_uuid}), do: {:start, github_uuid}

  def handle(%__MODULE__{}, %NewGithubReleasesFound{payload: payload, repo_owner: repo_owner, repo_name: repo_name}) do
    {:ok, sofware} = Core.software_by_github(repo_owner, repo_name)

    payload
    |> GithubReleases.merge_tags_and_releases(repo_owner, repo_name)
    |> Enum.map(fn(r) ->
      %PublishRelease{
        uuid: UUID.uuid4(),
        software_uuid: sofware.uuid,
        version_string: r.version_string,
        release_notes_url: r.release_notes_url,
        published_at: r.published_at,
        seen_at: "2017-09-02T16:19:42Z",
        pre_release: r.pre_release,
      }
    end)
  end

  def apply(%__MODULE__{} = state, _), do: state
end
