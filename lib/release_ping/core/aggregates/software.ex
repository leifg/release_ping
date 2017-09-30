defmodule ReleasePing.Core.Aggregates.Software do
  alias ReleasePing.Core.Aggregates.Software
  alias ReleasePing.Core.Commands.{AddSoftware, ChangeLicenses}
  alias ReleasePing.Core.Events.{SoftwareAdded, LicensesChanged}

  @type release_retrieval :: :github_release_poller
  @type type :: :application | :language | :library

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    website: String.t,
    github: String.t,
    licenses: [String.t],
    release_retrieval: release_retrieval,
  }

  defstruct [:uuid, :name, :website, :github, :licenses, :release_retrieval]

  @doc """
  Creates software
  """
  def execute(%Software{uuid: nil}, %AddSoftware{} = add) do
    %SoftwareAdded{
      uuid: add.uuid,
      name: add.name,
      type: add.type,
      website: add.website,
      github: add.github,
      licenses: add.licenses,
      release_retrieval: add.release_retrieval,
    }
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

  # state mutators

  def apply(%Software{} = software, %SoftwareAdded{} = added) do
    %Software{software |
      uuid: added.uuid,
      name: added.name,
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
end
