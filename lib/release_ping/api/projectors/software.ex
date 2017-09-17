defmodule ReleasePing.Api.Projectors.Software do
  use Commanded.Projections.Ecto, name: "Api.Projectors.Software"

  alias ReleasePing.Core.Events.{SoftwareAdded}
  alias ReleasePing.Api.Software
  alias ReleasePing.Api.Software.{License, Version}

  require Logger

  @known_licenses %{
    "Apache-2.0" => "Apache License 2.0",
    "GPL-3.0" => "GNU General Public License v3.0",
    "MIT" => "MIT License",
  }

  project %SoftwareAdded{} = added, %{stream_version: stream_version} do
    Ecto.Multi.insert(multi, :software, %Software{
      id: added.uuid,
      stream_version: stream_version,
      name: added.name,
      website: added.website,
      licenses: Enum.map(added.licenses, &map_license/1),
    })
  end

  defp map_license(spdx_id) do
    case Map.get(@known_licenses, spdx_id) do
      nil ->
        Logger.warn "Unknown License identifier #{spdx_id}"
        %License{spdx_id: spdx_id}
      name -> %License{spdx_id: spdx_id, name: name}
    end
  end
end
