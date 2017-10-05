defmodule ReleasePing.Core.Events.SoftwareAdded do
  @derive [Poison.Encoder]

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    type: String.t,
    website: String.t,
    github: String.t,
    licenses: [String.t],
    release_retrieval: String.t,
  }

  defstruct [
    uuid: nil,
    name: nil,
    type: nil,
    website: nil,
    github: nil,
    licenses: [],
    release_retrieval: nil,
  ]
end
