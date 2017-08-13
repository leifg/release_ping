defmodule ReleasePing.Core.Projectors.Software do
  use Commanded.Projections.Ecto, name: "Core.Projectors.Software"

  alias ReleasePing.Core.Events.{SoftwareAdded, ReleasePublished}
  alias ReleasePing.Core.Software
  alias ReleasePing.Repo

  project %SoftwareAdded{} = added, %{stream_version: stream_version} do
    Ecto.Multi.insert(multi, :software, %Software{
      uuid: added.uuid,
      stream_version: stream_version,
      name: added.name,
      website: added.website,
      licenses: added.licenses,
    })
  end

  project %ReleasePublished{uuid: uuid, software_uuid: software_uuid}, metadata do
    update_software(multi, software_uuid, metadata, [latest_release_uuid: uuid])
  end

  defp software_query(software_uuid) do
    from(a in Software, where: a.uuid == ^software_uuid)
  end

  defp update_software(multi, software_uuid, metadata, changes) do
    Ecto.Multi.update_all(multi, :software, software_query(software_uuid), [
      set: changes ++ [stream_version: metadata.stream_version]
    ], returning: true)
  end
end
