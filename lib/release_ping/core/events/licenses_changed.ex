defmodule ReleasePing.Core.Events.LicensesChanged do
  alias ReleasePing.Core.Aggregates.Software

  @derive [Poison.Encoder]

  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    licenses: [String.t],
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    licenses: [],
  ]
end