defmodule ReleasePing.Core.Events.SoftwareAdded do
  @derive [Poison.Encoder]

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    type: String.t,
    version_scheme: String.t,
    website: String.t,
    github: String.t,
    licenses: [String.t],
    release_retrieval: String.t,
  }

  defstruct [
    uuid: nil,
    name: nil,
    version_scheme: nil,
    type: nil,
    website: nil,
    github: nil,
    licenses: [],
    release_retrieval: nil,
  ]
end
