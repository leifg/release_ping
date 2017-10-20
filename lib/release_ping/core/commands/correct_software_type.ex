defmodule ReleasePing.Core.Commands.CorrectSoftwareType do
  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    type: String.t,
    reason: String.t,
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    type: nil,
    reason: nil,
  ]
end
