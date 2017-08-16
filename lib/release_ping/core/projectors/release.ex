defmodule ReleasePing.Core.Projectors.Release do
  use Commanded.Projections.Ecto, name: "Core.Projectors.Release"

  alias ReleasePing.Core.Events.ReleasePublished
  alias ReleasePing.Core.Release

  project %ReleasePublished{} = published, %{stream_version: stream_version} do
    Ecto.Multi.insert(multi, :software, %Release{
      uuid: published.uuid,
      stream_version: stream_version,
      software_uuid: published.software_uuid,
      version_string: nil,
      published_at: NaiveDateTime.from_iso8601!(published.published_at),
      pre_release: published.pre_release,
      release_notes_url: published.release_notes_url,
    })
  end
end
