defmodule ReleasePing.Incoming.Events.NewGithubReleasesFound do
  @derive [Poison.Encoder]

  @type t :: %__MODULE__{
    github_uuid: String.t,
    repo_owner: String.t,
    repo_name: String.t,
    last_cursor: String.t,
    payload: map,
  }

  defstruct [
    :github_uuid,
    :repo_owner,
    :repo_name,
    :last_cursor,
    :payload,
  ]
end
