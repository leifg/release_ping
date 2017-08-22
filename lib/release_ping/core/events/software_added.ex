defmodule ReleasePing.Core.Events.SoftwareAdded do
  alias ReleasePing.Core.Aggregates.Software

  @derive [Poison.Encoder]

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    website: String.t,
    github: String.t,
    licenses: [String.t],
    release_retrieval: Software.release_retrieval,
  }

  defstruct [
    uuid: nil,
    name: nil,
    website: nil,
    github: nil,
    licenses: [],
    release_retrieval: nil,
  ]
end
