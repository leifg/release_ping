defmodule ReleasePing.Core.Commands.PublishRelease do
  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    version_string: String.t,
    release_notes_url: String.t,
    published_at: DateTime.t,
    seen_at: DateTime.t,
    pre_release: boolean,
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    version_string: nil,
    release_notes_url: nil,
    version: nil,
    published_at: nil,
    seen_at: nil,
    pre_release: false,
  ]
end
