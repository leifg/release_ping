defmodule ReleasePing.Core.Aggregates.Software do
  alias ReleasePing.Core.Aggregates.Software
  alias ReleasePing.Core.Commands.{AddSoftware, ChangeLicenses, ChangeVersionScheme, PublishRelease}
  alias ReleasePing.Core.Events.{SoftwareAdded, LicensesChanged, ReleasePublished, VersionSchemeChanged}

  @type release_retrieval :: :github_release_poller
  @type type :: :application | :language | :library

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    type: type,
    version_scheme: Regex.t,
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
    version_scheme: nil,
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
      {:ok, _} -> %SoftwareAdded{
        uuid: add.uuid,
        name: add.name,
        type: add.type,
        version_scheme: add.version_scheme,
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
  def execute(%Software{existing_releases: existing_releases}, %PublishRelease{} = publish) do
    if MapSet.member?(existing_releases, publish.version_string) do
      nil
    else
      %ReleasePublished{
        uuid: publish.uuid,
        software_uuid: publish.software_uuid,
        version_string: publish.version_string,
        release_notes_url: publish.release_notes_url,
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
        {:ok, _} -> %VersionSchemeChanged{
          uuid: change.uuid,
          software_uuid: software.uuid,
          version_scheme: change.version_scheme,
        }
      end
    end
  end

  # state mutators

  def apply(%Software{} = software, %SoftwareAdded{} = added) do
    %Software{software |
      uuid: added.uuid,
      name: added.name,
      type: added.type,
      version_scheme: added.version_scheme,
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

  defp validate_version_scheme(nil), do: {:ok, nil}
  defp validate_version_scheme(version_scheme), do: Regex.compile version_scheme
end
