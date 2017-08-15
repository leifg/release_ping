defmodule ReleasePing.Core.Aggregates.Software do
  alias ReleasePing.Core.Aggregates.Software
  alias ReleasePing.Core.Commands.AddSoftware
  alias ReleasePing.Core.Events.SoftwareAdded

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    website: String.t,
    github: String.t,
    licenses: [String.t],
    releases: [String.t],
  }

  defstruct [:uuid, :name, :website, :github, :releases, :licenses]

  @doc """
  Creates software
  """
  def execute(%Software{uuid: nil}, %AddSoftware{} = add) do
    %SoftwareAdded{
      uuid: add.uuid,
      name: add.name,
      website: add.website,
      github: add.github,
      licenses: add.licenses,
    }
  end

  # state mutators

  def apply(%Software{} = software, %SoftwareAdded{} = added) do
    %Software{software |
      uuid: added.uuid,
      name: added.name,
      website: added.website,
      github: added.github,
      licenses: added.licenses,
      releases: [],
    }
  end
end
