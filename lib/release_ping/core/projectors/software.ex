defmodule ReleasePing.Core.Projectors.Software do
  use Commanded.Projections.Ecto, name: "Core.Projectors.Software"

  alias ReleasePing.Core.Events.SoftwareAdded
  alias ReleasePing.Core.Software

  project %SoftwareAdded{} = added, %{stream_version: stream_version} do
    Ecto.Multi.insert(multi, :software, %Software{
      uuid: added.uuid,
      stream_version: stream_version,
      name: added.name,
      website: added.website,
      licenses: added.licenses,
    })
  end
end
