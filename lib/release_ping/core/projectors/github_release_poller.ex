defmodule ReleasePing.Core.Projectors.GithubReleasePoller do
  use Commanded.Projections.Ecto, name: "Core.Projectors.GithubReleasePoller"

  alias ReleasePing.Core.Events.{ReleasePublished, SoftwareAdded}
  alias ReleasePing.Core.GithubReleasePoller

  project %SoftwareAdded{release_retrieval: :github_release_poller} = added, %{stream_version: stream_version} do
    Ecto.Multi.insert(multi, :software, %GithubReleasePoller{
      uuid: UUID.uuid4(),
      stream_version: stream_version,
      software_uuid: added.uuid,
      repository: added.github,
    })
  end

  project %ReleasePublished{} = published, %{} do
    existing = ReleasePing.Repo.get_by(ReleasePing.Core.GithubReleasePoller, software_uuid: published.software_uuid)

    update_cursor(multi, existing, published.github_cursor)
  end

  defp update_cursor(multi, _existing, nil), do: multi
  defp update_cursor(multi, existing_software, {cursor_type, cursor_value}) do
    changeset = Ecto.Changeset.change(existing_software, %{cursor_field(cursor_type) => cursor_value})

    Ecto.Multi.update(multi, :github_release_pollers, changeset)
  end
  defp update_cursor(multi, existing_software, last_cursor) do
    [cursor_type, cursor_value] = String.split(last_cursor, ":")

    update_cursor(multi, existing_software, {cursor_type, cursor_value})
  end

  defp cursor_field("tags"), do: :last_cursor_tags
  defp cursor_field("releases"), do: :last_cursor_releases
end
