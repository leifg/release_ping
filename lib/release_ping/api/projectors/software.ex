defmodule ReleasePing.Api.Projectors.Software do
  use Commanded.Projections.Ecto, name: "Api.Projectors.Software"

  alias ReleasePing.Repo
  alias ReleasePing.Core.Events.{LicensesChanged, SoftwareAdded, ReleasePublished}
  alias ReleasePing.Core.Version.SemanticVersion
  alias ReleasePing.Api.{Software, VersionUtils}
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

  project %ReleasePublished{} = published, _metadata do
    update_software(multi, published)
  end

  project %LicensesChanged{} = changed, _metadata do
    update_software(multi, changed)
  end

  defp update_software(multi, %ReleasePublished{} = published) do
    existing_software = Repo.get(Software, published.software_uuid)
    existing_stable = existing_software.latest_version_stable
    existing_unstable = existing_software.latest_version_unstable

    sem_ver = SemanticVersion.parse(published.version_string)

    new_version = %Version{
      id: published.uuid,
      name: SemanticVersion.name(published.version_string),
      major: sem_ver.major,
      minor: sem_ver.minor,
      patch: sem_ver.patch,
      release_notes_url: published.release_notes_url,
      published_at: published.published_at,
    }

    stable_version_to_set = cond do
      published.pre_release -> existing_stable
      existing_stable == nil -> new_version
      VersionUtils.compare(new_version, existing_stable) == :gt -> new_version
      true -> existing_stable
    end

    unstable_version_to_set = cond do
      existing_unstable == nil -> new_version
      VersionUtils.compare(new_version, existing_unstable) == :gt -> new_version
      true -> existing_unstable
    end

    changeset = existing_software
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_embed(:latest_version_stable, stable_version_to_set)
      |> Ecto.Changeset.put_embed(:latest_version_unstable, unstable_version_to_set)

    Ecto.Multi.update(multi, :api_software, changeset)
  end

  defp update_software(multi, %LicensesChanged{} = changed) do
    existing_software = Repo.get(Software, changed.software_uuid)
    changeset = existing_software
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_embed(:licenses, Enum.map(changed.licenses, &map_license/1))

    Ecto.Multi.update(multi, :api_software, changeset)
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
