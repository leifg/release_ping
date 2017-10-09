defmodule ReleasePing.Core.Events.VersionSchemeChanged do
  @derive [Poison.Encoder]

  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    version_scheme: String.t,
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    version_scheme: nil,
  ]
end
