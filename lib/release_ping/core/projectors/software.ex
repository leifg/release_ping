defmodule ReleasePing.Core.Projectors.Software do
  use Commanded.Projections.Ecto, name: "Core.Projectors.Software"

  alias ReleasePing.Core.Events.SoftwareAdded
  alias ReleasePing.Core.Software

  project %SoftwareAdded{} = added, %{stream_version: stream_version} do
    Ecto.Multi.insert(multi, :software, %Software{
      uuid: added.uuid,
      stream_version: stream_version,
      name: added.name,
      type: added.type,
      website: added.website,
      github: added.github,
      licenses: added.licenses,
      release_retrieval: added.release_retrieval,
    })
  end
end
