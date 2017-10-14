defmodule ReleasePing.Core.Commands.CorrectReleaseNotesUrlTemplate do
  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    release_notes_url_template: String.t,
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    release_notes_url_template: nil,
  ]
end
