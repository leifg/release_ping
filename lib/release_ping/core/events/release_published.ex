defmodule ReleasePing.Core.Events.ReleasePublished do
  @derive [Poison.Encoder]
  defstruct [
    uuid: nil,
    software_uuid: nil,
    version_string: nil,
    release_notes_url: nil,
    published_at: nil,
    seen_at: nil,
    pre_release: false,
  ]
end
