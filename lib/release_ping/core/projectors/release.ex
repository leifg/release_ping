defmodule ReleasePing.Core.Projectors.Release do
  use Commanded.Projections.Ecto, name: "Core.Projectors.Release"

  alias ReleasePing.Core.Events.ReleasePublished
  alias ReleasePing.Core.Release
  alias ReleasePing.Core.Version.SemanticVersion

  project %ReleasePublished{} = published, %{stream_version: stream_version} do
    version = SemanticVersion.parse(published.version_string)
    Ecto.Multi.insert(multi, :software, %Release{
      uuid: published.uuid,
      stream_version: stream_version,
      software_uuid: published.software_uuid,
      version_string: published.version_string,
      published_at: format_date(published.published_at),
      seen_at: format_date(published.seen_at),
      major_version: version.major,
      minor_version: version.minor,
      patch_version: version.patch,
      pre_release: published.pre_release,
      release_notes_url: published.release_notes_url,
    })
  end

  defp format_date(nil), do: nil
  defp format_date(date_time), do: NaiveDateTime.from_iso8601!(date_time)
end
