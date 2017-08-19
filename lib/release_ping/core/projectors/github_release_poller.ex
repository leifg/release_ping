defmodule ReleasePing.Core.Projectors.GithubReleasePoller do
  use Commanded.Projections.Ecto, name: "Core.Projectors.GithubReleasePoller"

  alias ReleasePing.Core.Events.SoftwareAdded
  alias ReleasePing.Core.GithubReleasePoller

  project %SoftwareAdded{release_retrieval: "github_release_poller"} = added, %{stream_version: stream_version} do
    Ecto.Multi.insert(multi, :software, %GithubReleasePoller{
      uuid: UUID.uuid4(),
      stream_version: stream_version,
      software_uuid: added.uuid,
      repository: added.github,
    })
  end
end
