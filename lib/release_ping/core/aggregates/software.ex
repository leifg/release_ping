defmodule ReleasePing.Core.Aggregates.Software do
  alias ReleasePing.Core.Aggregates.Software
  alias ReleasePing.Core.Commands.{AddSoftware, ChangeLicenses, ChangeVersionScheme}
  alias ReleasePing.Core.Events.{SoftwareAdded, LicensesChanged, VersionSchemeChanged}

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
  }

  defstruct [:uuid, :name, :type, :version_scheme, :website, :github, :licenses, :release_retrieval]

  @doc """
  Creates software
  """
  def execute(%Software{uuid: nil}, %AddSoftware{} = add) do
    case serialize_vesion_scheme(add.version_scheme) do
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
      case serialize_vesion_scheme(change.version_scheme) do
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
      version_scheme: deserialize_version_scheme(added.version_scheme),
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
      version_scheme: deserialize_version_scheme(change.version_scheme),
    }
  end

  defp serialize_vesion_scheme(nil), do: {:ok, nil}
  defp serialize_vesion_scheme(version_scheme), do: Regex.compile version_scheme

  defp deserialize_version_scheme(nil), do: nil
  defp deserialize_version_scheme(version_scheme), do: Regex.compile!(version_scheme)
end
