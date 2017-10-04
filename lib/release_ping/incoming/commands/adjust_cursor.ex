defmodule ReleasePing.Incoming.Commands.AdjustCursor do
  @type cursor_type :: :tags | :releases

  @type t :: %__MODULE__{
    uuid: String.t,
    github_uuid: String.t,
    repo_owner: String.t,
    repo_name: String.t,
    type: cursor_type,
    cursor: String.t
  }

  defstruct [:uuid, :github_uuid, :repo_owner, :repo_name, :type, :cursor]
end
