defmodule ReleasePing.Incoming.Commands.PollGithubReleases do
  @type t :: %__MODULE__{
    github_uuid: String.t,
    repo_owner: String.t,
    repo_name: String.t,
  }

  defstruct [:github_uuid, :repo_owner, :repo_name]
end
