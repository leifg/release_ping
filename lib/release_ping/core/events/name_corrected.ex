defmodule ReleasePing.Core.Events.NameCorrected do
  @type t :: %__MODULE__{
          uuid: String.t(),
          software_uuid: String.t(),
          name: String.t(),
          reason: String.t()
        }

  defstruct uuid: nil,
            software_uuid: nil,
            name: nil,
            reason: nil
end
