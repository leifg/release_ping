defmodule ReleasePing.Scheduler do
  alias ReleasePing.Incoming.GithubEndpoint
  alias ReleasePing.Incoming.Commands.PollGithubReleases

  require Logger

  use Quantum.Scheduler, otp_app: :release_ping

  @to_reset MapSet.new([
    {"erlang", "otp"},
    {"fsharp", "fsharp"},
    {"golang", "go"},
  ])

  def poll_releases do
    Logger.info("Polling Releases")

    endpoint = GithubEndpoint.least_used()

    ReleasePing.Core.github_release_pollers() |> Enum.each(fn(grp) ->
      [repo_owner, repo_name] = String.split(grp.repository, "/")
      if MapSet.member?(@to_reset, {repo_owner, repo_name}) do
        adjust_cursor(repo_owner, repo_name, endpoint, grp.software_uuid)
      end

      ReleasePing.Router.dispatch(%PollGithubReleases{
        uuid: UUID.uuid4(),
        github_uuid: endpoint.uuid,
        software_uuid: grp.software_uuid,
        repo_owner: repo_owner,
        repo_name: repo_name,
      })
    end)
  end

  defp adjust_cursor(repo_owner, repo_name, github_endpoint, software_uuid) do
    Logger.info("Resetting Cursor for #{repo_owner}/#{repo_name}")
    command = %ReleasePing.Incoming.Commands.AdjustCursor{
      uuid: UUID.uuid4(),
      github_uuid: github_endpoint.uuid,
      software_uuid: software_uuid,
      repo_owner: repo_owner,
      repo_name: repo_name,
      type: :tags,
      cursor: nil
    }

    ReleasePing.Router.dispatch(command)
  end
end
