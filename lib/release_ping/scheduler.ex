defmodule ReleasePing.Scheduler do
  alias ReleasePing.Incoming.GithubEndpoint
  alias ReleasePing.Incoming.Commands.PollGithubReleases

  require Logger

  use Quantum.Scheduler, otp_app: :release_ping

  def poll_releases do
    Logger.info("Polling Releases")

    endpoint = GithubEndpoint.least_used()

    ReleasePing.Core.github_release_pollers() |> Enum.each(fn(grp) ->
      [repo_owner, repo_name] = String.split(grp.repository, "/")
      ReleasePing.Router.dispatch(%PollGithubReleases{
        uuid: UUID.uuid4(),
        github_uuid: endpoint.uuid,
        repo_owner: repo_owner,
        repo_name: repo_name,
      })
    end)
  end
end
