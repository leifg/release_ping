defmodule ReleasePing.Core.Projectors.Software do
  use Commanded.Projections.Ecto, name: "Core.Projectors.Software"

  alias ReleasePing.Core.Events.{
    LicensesChanged,
    NameCorrected,
    ReleaseNotesUrlTemplateCorrected,
    SoftwareAdded,
    SoftwareTypeCorrected,
    SlugCorrected,
    VersionSchemeChanged,
    WebsiteCorrected
  }

  alias ReleasePing.Core.Software
  alias ReleasePing.Repo

  project %SoftwareAdded{} = added, %{stream_version: stream_version} do
    changeset =
      case Repo.get_by(Software, github: added.github) do
        nil ->
          %Software{
            uuid: added.uuid,
            stream_version: stream_version,
            name: added.name,
            type: added.type,
            slug: added.slug,
            version_scheme: serialize_regex(added.version_scheme),
            release_notes_url_template: added.release_notes_url_template,
            website: added.website,
            github: added.github,
            licenses: added.licenses,
            release_retrieval: added.release_retrieval
          }

        software ->
          software
      end
      |> Ecto.Changeset.change()

    Ecto.Multi.insert_or_update(multi, :software, changeset)
  end

  project %LicensesChanged{} = changed, _metadata do
    update_software(multi, changed.software_uuid, :licenses, changed.licenses)
  end

  project %WebsiteCorrected{} = corrected, _metadata do
    update_software(multi, corrected.software_uuid, :website, corrected.website)
  end

  project %NameCorrected{} = corrected, _metadata do
    update_software(multi, corrected.software_uuid, :name, corrected.name)
  end

  project %VersionSchemeChanged{} = corrected, _metadata do
    update_software(
      multi,
      corrected.software_uuid,
      :version_scheme,
      serialize_regex(corrected.version_scheme)
    )
  end

  project %ReleaseNotesUrlTemplateCorrected{} = corrected, _metadata do
    update_software(
      multi,
      corrected.software_uuid,
      :release_notes_url_template,
      corrected.release_notes_url_template
    )
  end

  project %SoftwareTypeCorrected{} = corrected, _metadata do
    update_software(multi, corrected.software_uuid, :type, corrected.type)
  end

  project %SlugCorrected{} = corrected, _metadata do
    update_software(multi, corrected.software_uuid, :slug, corrected.slug)
  end

  defp update_software(multi, software_uuid, field_name, value) do
    existing_software = Repo.get(Software, software_uuid)

    changeset =
      existing_software
      |> Ecto.Changeset.change(%{field_name => value})

    Ecto.Multi.update(multi, :software, changeset)
  end

  defp serialize_regex(nil), do: nil
  defp serialize_regex(regex), do: Regex.source(regex)
end
