defmodule ReleasePing.Core.Commands.PublishRelease do
  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    version: ReleasePing.Core.Aggregates.Release.version,
    release_notes_url: String.t,
    published_at: DateTime.t,
    pre_release: boolean,
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    version: nil,
    release_notes_url: nil,
    version: nil,
    published_at: nil,
    pre_release: false,
  ]
end
