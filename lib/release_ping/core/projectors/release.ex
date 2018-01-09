defmodule ReleasePing.Core.Projectors.Release do
  use Commanded.Projections.Ecto, name: "Core.Projectors.Release"

  alias ReleasePing.Core.Events.{
    ReleasePublished,
    ReleaseNotesUrlAdjusted
  }

  alias ReleasePing.Core.Release

  project %ReleasePublished{} = published, %{stream_version: stream_version} do
    version = published.version_info

    Ecto.Multi.insert(multi, :software, %Release{
      uuid: published.uuid,
      stream_version: stream_version,
      software_uuid: published.software_uuid,
      version_string: published.version_string,
      published_at: published.published_at,
      seen_at: published.seen_at,
      major_version: version.major,
      minor_version: version.minor,
      patch_version: version.patch,
      pre_release: published.pre_release,
      release_notes_url: published.release_notes_url
    })
  end

  project %ReleaseNotesUrlAdjusted{} = adjusted, _metadata do
    update_release(
      multi,
      adjusted.software_uuid,
      adjusted.version_string,
      :release_notes_url,
      adjusted.release_notes_url
    )
  end

  defp update_release(multi, software_uuid, version_string, field_name, value) do
    existing_release =
      ReleasePing.Repo.get_by(
        Release,
        software_uuid: software_uuid,
        version_string: version_string
      )

    changeset =
      existing_release
      |> Ecto.Changeset.change(%{field_name => value})

    Ecto.Multi.update(multi, :release, changeset)
  end
end
