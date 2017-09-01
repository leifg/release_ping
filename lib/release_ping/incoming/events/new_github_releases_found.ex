defmodule ReleasePing.Incoming.Events.NewGithubReleasesFound do
  @derive [Poison.Encoder]

  @type t :: %__MODULE__{
    uuid: String.t,
    github_uuid: String.t,
    repo_owner: String.t,
    repo_name: String.t,
    last_cursor_releases: String.t,
    payload: map,
  }

  defstruct [
    :uuid,
    :github_uuid,
    :repo_owner,
    :repo_name,
    :last_cursor_releases,
    :payload,
  ]
end
