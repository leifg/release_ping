defmodule ReleasePing.Core.Aggregates.Software do
  alias ReleasePing.Core.Aggregates.Software
  alias ReleasePing.Core.Commands.{
    AddSoftware,
    ChangeLicenses,
    ChangeVersionScheme,
    CorrectName,
    CorrectReleaseNotesUrlTemplate,
    CorrectSlug,
    CorrectSoftwareType,
    CorrectWebsite,
    PublishRelease
  }
  alias ReleasePing.Core.Events.{
    SoftwareAdded,
    LicensesChanged,
    NameCorrected,
    ReleasePublished,
    ReleaseNotesUrlTemplateCorrected,
    SlugCorrected,
    SoftwareTypeCorrected,
    VersionSchemeChanged,
    WebsiteCorrected
  }
  alias ReleasePing.Core.Version.VersionInfo

  @type release_retrieval :: :github_release_poller
  @type type :: :application | :language | :library

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    type: type,
    slug: String.t,
    version_scheme: Regex.t,
    release_notes_url_template: String.t,
    display_version_template: String.t,
    website: String.t,
    github: String.t,
    licenses: [String.t],
    release_retrieval: release_retrieval,
    existing_releases: MapSet.t(String.t),
  }

  defstruct [
    uuid: nil,
    name: nil,
    type: nil,
    slug: nil,
    version_scheme: nil,
    release_notes_url_template: nil,
    display_version_template: nil,
    website: nil,
    github: nil,
    licenses: nil,
    release_retrieval: nil,
    existing_releases: MapSet.new(),
  ]

  @doc """
  Creates software
  """
  def execute(%Software{uuid: nil}, %AddSoftware{} = add) do
    case validate_version_scheme(add.version_scheme) do
      {:error, {reason, position}} -> {:error, {:regex_error, "'#{reason}' at position #{position}"}}
      {:ok, version_scheme_regex} -> %SoftwareAdded{
        uuid: add.uuid,
        name: add.name,
        slug: add.slug,
        type: add.type,
        version_scheme: version_scheme_regex,
        release_notes_url_template: add.release_notes_url_template,
        display_version_template: add.display_version_template,
        website: add.website,
        github: add.github,
        licenses: add.licenses,
        release_retrieval: add.release_retrieval,
      }
    end
  end

  @doc """
  Publishes Release
  """
  def execute(%Software{} = software, %PublishRelease{} = publish) do
    cond do
      is_nil(publish.version_string) -> nil
      MapSet.member?(software.existing_releases, publish.version_string) -> nil
      true ->
        version_info = publish.version_string
                        |> VersionInfo.parse(software.version_scheme)
                        |> VersionInfo.published_at(publish.published_at)
        extended_version_info = extended_version_info(version_info, publish.version_string)
        release_notes_url = calculate_release_notes_url(
          software.release_notes_url_template,
          publish.release_notes_url,
          extended_version_info
        )
        display_version = EEx.eval_string(
          software.display_version_template , assigns: extended_version_info
        )

        %ReleasePublished{
          uuid: publish.uuid,
          software_uuid: publish.software_uuid,
          version_string: publish.version_string,
          version_info: version_info,
          release_notes_url: release_notes_url,
          display_version: display_version,
          github_cursor: publish.github_cursor,
          published_at: publish.published_at,
          seen_at: publish.seen_at,
          pre_release: publish.pre_release,
        }
    end
  end

  @doc """
  Changes Licenses
  """
  def execute(%Software{} = software, %ChangeLicenses{} = change) do
    if software.licenses == change.licenses do
      nil
    else
      %LicensesChanged{
        uuid: change.uuid,
        software_uuid: software.uuid,
        licenses: change.licenses,
      }
    end
  end

  @doc """
  Changes VersionScheme
  """
  def execute(%Software{} = software, %ChangeVersionScheme{} = change) do
    if software.version_scheme == change.version_scheme do
      nil
    else
      case validate_version_scheme(change.version_scheme) do
        {:error, {reason, position}} -> {:error, {:regex_error, "'#{reason}' at position #{position}"}}
        {:ok, version_scheme_regex} -> %VersionSchemeChanged{
          uuid: change.uuid,
          software_uuid: software.uuid,
          version_scheme: version_scheme_regex,
        }
      end
    end
  end

  @doc """
  Corrects Website
  """
  def execute(%Software{} = software, %CorrectWebsite{} = correct) do
    if software.website == correct.website do
      nil
    else
      %WebsiteCorrected{
        uuid: correct.uuid,
        software_uuid: software.uuid,
        website: correct.website,
      }
    end
  end

  @doc """
  Corrects Name
  """
  def execute(%Software{} = software, %CorrectName{} = correct) do
    if software.name == correct.name do
      nil
    else
      %NameCorrected{
        uuid: correct.uuid,
        software_uuid: software.uuid,
        name: correct.name,
        reason: correct.reason,
      }
    end
  end

  @doc """
  Corrects SoftwareType
  """
  def execute(%Software{} = software, %CorrectSoftwareType{} = correct) do
    if software.type == correct.type do
      nil
    else
      %SoftwareTypeCorrected{
        uuid: correct.uuid,
        software_uuid: software.uuid,
        type: correct.type,
        reason: correct.reason,
      }
    end
  end

  @doc """
  Corrects SoftwareType
  """
  def execute(%Software{} = software, %CorrectSlug{} = correct) do
    if software.slug == correct.slug do
      nil
    else
      %SlugCorrected{
        uuid: correct.uuid,
        software_uuid: software.uuid,
        slug: correct.slug,
        reason: correct.reason,
      }
    end
  end


  @doc """
  Corrects ReleaseNotesUrlTemplate
  """
  def execute(%Software{} = software, %CorrectReleaseNotesUrlTemplate{} = correct) do
    if software.release_notes_url_template == correct.release_notes_url_template do
      nil
    else
      %ReleaseNotesUrlTemplateCorrected{
        uuid: correct.uuid,
        software_uuid: software.uuid,
        release_notes_url_template: correct.release_notes_url_template,
      }
    end
  end

  # state mutators

  def apply(%Software{} = software, %SoftwareAdded{} = added) do
    %Software{software |
      uuid: added.uuid,
      name: added.name,
      type: added.type,
      slug: added.slug,
      version_scheme: added.version_scheme,
      release_notes_url_template: added.release_notes_url_template,
      display_version_template: added.display_version_template,
      website: added.website,
      github: added.github,
      licenses: added.licenses,
      release_retrieval: added.release_retrieval,
    }
  end

  def apply(%Software{} = software, %LicensesChanged{} = change) do
    %Software{software |
      licenses: change.licenses,
    }
  end

  def apply(%Software{} = software, %VersionSchemeChanged{} = change) do
    %Software{software |
      version_scheme: change.version_scheme,
    }
  end

  def apply(%Software{} = software, %ReleasePublished{version_string: version_string}) do
    %Software{software |
      existing_releases: MapSet.put(software.existing_releases, version_string)
    }
  end

  def apply(%Software{} = software, %WebsiteCorrected{} = corrected) do
    %Software{software |
      website: corrected.website,
    }
  end

  def apply(%Software{} = software, %NameCorrected{} = corrected) do
    %Software{software |
      name: corrected.name,
    }
  end

  def apply(%Software{} = software, %SoftwareTypeCorrected{} = corrected) do
    %Software{software |
      type: corrected.type,
    }
  end

  def apply(%Software{} = software, %SlugCorrected{} = corrected) do
    %Software{software |
      slug: corrected.slug,
    }
  end

  def apply(%Software{} = software, %ReleaseNotesUrlTemplateCorrected{} = corrected) do
    %Software{software |
      release_notes_url_template: corrected.release_notes_url_template,
    }
  end

  defp validate_version_scheme(nil), do: {:ok, nil}
  defp validate_version_scheme(version_scheme), do: Regex.compile version_scheme

  defp calculate_release_notes_url(release_notes_url_template, release_notes_url, version_info) do
    case release_notes_url do
      nil ->
        EEx.eval_string(release_notes_url_template, assigns: version_info)
      release_notes_url -> release_notes_url
    end
  end

  defp extended_version_info(version_info, version_string) do
    version_info |> Map.from_struct() |> Map.merge(%{version_string: version_string})
  end
end
