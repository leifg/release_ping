defmodule ReleasePing.Core.Events.WebsiteCorrected do
  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    website: String.t,
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    website: nil,
  ]
end
