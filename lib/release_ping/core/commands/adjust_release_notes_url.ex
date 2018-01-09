defmodule ReleasePing.Core.Commands.AdjustReleaseNotesUrl do
  @type t :: %__MODULE__{
          uuid: String.t(),
          software_uuid: String.t(),
          version_string: String.t(),
          release_notes_url: String.t()
        }

  defstruct uuid: nil,
            software_uuid: nil,
            version_string: nil,
            release_notes_url: nil
end
