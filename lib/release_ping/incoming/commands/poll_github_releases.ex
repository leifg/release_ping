defmodule ReleasePing.Incoming.Commands.PollGithubReleases do
  @type t :: %__MODULE__{
    uuid: String.t,
    github_uuid: String.t,
    repo_owner: String.t,
    repo_name: String.t,
  }

  defstruct [:uuid, :github_uuid, :repo_owner, :repo_name]
end
