defmodule ReleasePing.Incoming.Events.NewGithubReleasesFound do
  @type t :: %__MODULE__{
    uuid: String.t,
    github_uuid: String.t,
    software_uuid: String.t,
    repo_owner: String.t,
    repo_name: String.t,
    last_cursor_releases: String.t,
    last_cursor_tags: String.t,
    seen_at: String.t,
    payloads: [map],
  }

  defstruct [
    :uuid,
    :github_uuid,
    :software_uuid,
    :repo_owner,
    :repo_name,
    :last_cursor_releases,
    :last_cursor_tags,
    :seen_at,
    :payloads,
  ]
end
