defmodule ReleasePing.Scheduler do
  alias ReleasePing.Incoming.GithubEndpoint
  alias ReleasePing.Incoming.Commands.PollGithubReleases

  require Logger

  use Quantum.Scheduler, otp_app: :release_ping

  @to_adjust [
    {"erlang", "otp"},
    {"fsharp", "fsharp"},
    {"golang", "go"},

  def poll_releases do
    Logger.info("Polling Releases")

    endpoint = GithubEndpoint.least_used()

    Enum.each(@to_adjust, fn({repo_owner, repo_name}) ->
      adjust_cursor(repo_owner, repo_name, endpoint)
    end)

    ReleasePing.Core.github_release_pollers() |> Enum.each(fn(grp) ->
      [repo_owner, repo_name] = String.split(grp.repository, "/")
      ReleasePing.Router.dispatch(%PollGithubReleases{
        uuid: UUID.uuid4(),
        github_uuid: endpoint.uuid,
        software_uuid: grp.software_uuid,
        repo_owner: repo_owner,
        repo_name: repo_name,
      })
    end)
  end

  defp adjust_cursor(repo_owner, repo_name, github_endpoint) do
    import Ecto.Query, only: [from: 2]
    github = "#{repo_owner}/#{repo_name}"

    query = from grp in "github_release_pollers",
              where: grp.repository == ^github,
              select: [grp.software_uuid, grp.last_cursor_tags]

    case ReleasePing.Repo.one(query) do
      nil -> :ok
      [_software_uuid, nil] -> :ok
      [software_uuid, new_cursor] ->
        Logger.info("Adjust Cursor for #{repo_owner}/#{repo_name} to #{new_cursor}")
        command = %ReleasePing.Incoming.Commands.AdjustCursor{
          uuid: UUID.uuid4(),
          github_uuid: github_endpoint.uuid,
          software_uuid: UUID.binary_to_string!(software_uuid),
          repo_owner: repo_owner,
          repo_name: repo_name,
          type: :tags,
          cursor: new_cursor
        }

        ReleasePing.Router.dispatch(command)
    end
  end
end
