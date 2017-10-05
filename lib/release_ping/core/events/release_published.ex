defmodule ReleasePing.Core.Events.ReleasePublished do
  @derive [Poison.Encoder]

  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    version_string: String.t,
    release_notes_url: String.t,
    published_at: String.t, # ISO 8601 Datetime
    seen_at: String.t, # ISO 8601 Datetime
    github_cursor: String.t,
    pre_release: boolean,
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    version_string: nil,
    release_notes_url: nil,
    published_at: nil,
    seen_at: nil,
    github_cursor: nil,
    pre_release: false,
  ]
end
