defmodule ReleasePing.Api.Projectors.Software do
  use Commanded.Projections.Ecto, name: "Api.Projectors.Software"

  alias ReleasePing.Repo
  alias ReleasePing.Core.Events.{
    LicensesChanged,
    NameCorrected,
    SoftwareAdded,
    ReleasePublished,
    ReleaseNotesUrlTemplateCorrected,
    SlugCorrected,
    WebsiteCorrected
  }
  alias ReleasePing.Api.{Software, VersionUtils}
  alias ReleasePing.Api.Software.{License, Version}

  require Logger

  @known_licenses %{
    "Apache-2.0" => "Apache License 2.0",
    "GPL-2.0" => "GNU General Public License v2.0",
    "GPL-3.0" => "GNU General Public License v3.0",
    "BSD-2-Clause" => "BSD 2-clause",
    "BSD-3-Clause" => "BSD 3-clause",
    "BSL-1.0" => "Boost Software License 1.0",
    "EPL-1.0" =>  "Eclipse Public License 1.0",
    "LGPL-2.1" => "GNU LGPLv2.1",
    "LGPL-3.0" => "GNU LGPLv3.0",
    "MIT" => "MIT License",
    "PHP-3.0" => "PHP License v3.0",
    "PHP-3.01" => "PHP License v3.01",
    "Ruby" => "Ruby License",
  }

  project %SoftwareAdded{} = added, %{stream_version: stream_version} do
    Ecto.Multi.insert(multi, :software, %Software{
      id: added.uuid,
      stream_version: stream_version,
      name: added.name,
      slug: added.slug,
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

  project %WebsiteCorrected{} = corrected, _metadata do
    update_software(multi, corrected)
  end

  project %NameCorrected{} = corrected, _metadata do
    update_software(multi, corrected)
  end

  project %SlugCorrected{} = corrected, _metadata do
    update_software(multi, corrected)
  end

  project %ReleaseNotesUrlTemplateCorrected{} = corrected, _metadata do
    update_software(multi, corrected)
  end

  defp update_software(multi, %ReleasePublished{} = published) do
    existing_software = Repo.get(Software, published.software_uuid)
    existing_stable = existing_software.latest_version_stable
    existing_unstable = existing_software.latest_version_unstable

    version_info = published.version_info

    new_version = %Version{
      id: published.uuid,
      name: published.display_version,
      version_string: published.version_string,
      major: version_info.major,
      minor: version_info.minor,
      patch: version_info.patch,
      pre_release: version_info.pre_release,
      build_metadata: version_info.build_metadata,
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

  defp update_software(multi, %WebsiteCorrected{} = corrected) do
    existing_software = Repo.get(Software, corrected.software_uuid)
    changeset = existing_software
      |> Ecto.Changeset.change(%{website: corrected.website})

    Ecto.Multi.update(multi, :api_software, changeset)
  end

  defp update_software(multi, %NameCorrected{} = corrected) do
    existing_software = Repo.get(Software, corrected.software_uuid)
    changeset = existing_software
      |> Ecto.Changeset.change(%{name: corrected.name})

    Ecto.Multi.update(multi, :api_software, changeset)
  end

  defp update_software(multi, %SlugCorrected{} = corrected) do
    existing_software = Repo.get(Software, corrected.software_uuid)
    changeset = existing_software
      |> Ecto.Changeset.change(%{slug: corrected.slug})

    Ecto.Multi.update(multi, :api_software, changeset)
  end

  defp update_software(multi, %ReleaseNotesUrlTemplateCorrected{} = corrected) do
    existing_software = Repo.get(Software, corrected.software_uuid)

    new_stable_rnu = EEx.eval_string(corrected.release_notes_url_template, assigns: Map.from_struct(existing_software.latest_version_stable))
    new_unstable_rnu = EEx.eval_string(corrected.release_notes_url_template, assigns: Map.from_struct(existing_software.latest_version_unstable))

    latest_changeset_stable = Ecto.Changeset.change(existing_software.latest_version_stable, release_notes_url: new_stable_rnu)
    latest_changeset_unstable = Ecto.Changeset.change(existing_software.latest_version_unstable, release_notes_url: new_unstable_rnu)

    changeset = existing_software
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_embed(:latest_version_stable, latest_changeset_stable)
      |> Ecto.Changeset.put_embed(:latest_version_unstable, latest_changeset_unstable)

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
