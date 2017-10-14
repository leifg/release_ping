defmodule ReleasePing.Core.Commands.PublishRelease do
  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    version_string: String.t,
    release_notes_url: String.t,
    github_cursor: String.t,
    published_at: String.t, # ISO 8601 Datetime
    seen_at: String.t, # ISO 8601 Datetime
    pre_release: boolean,
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    version_string: nil,
    release_notes_url: nil,
    github_cursor: nil,
    published_at: nil,
    seen_at: nil,
    pre_release: false,
  ]
end
