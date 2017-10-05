defmodule ReleasePing.Incoming.Events.CursorAdjusted do
  @derive [Poison.Encoder]

  @type t :: %__MODULE__{
    uuid: String.t,
    github_uuid: String.t,
    software_uuid: String.t,
    repo_owner: String.t,
    repo_name: String.t,
    type: ReleasePing.Incoming.Commands.AdjustCursor.cursor_type,
    cursor: String.t
  }

  defstruct [
    :uuid,
    :github_uuid,
    :software_uuid,
    :repo_owner,
    :repo_name,
    :type,
    :cursor,
  ]
end
