defmodule ReleasePing.Scheduler do
  alias ReleasePing.Incoming.GithubEndpoint
  alias ReleasePing.Incoming.Commands.PollGithubReleases

  require Logger

  use Quantum.Scheduler, otp_app: :release_ping

  def poll_releases do
    Logger.info("Polling Releases")

    endpoint = GithubEndpoint.least_used()

    adjust_cursor_for_erlang(endpoint)

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

  defp adjust_cursor_for_erlang(github_endpoint) do
    import Ecto.Query, only: [from: 2]
    query = from grp in "github_release_pollers",
              where: grp.repository == "erlang/otp",
              select: [grp.software_uuid, grp.last_cursor_tags]

    [erlang_uuid, new_cursor] = ReleasePing.Repo.one(query)

    if new_cursor != nil do
      Logger.info("Adjust Cursor to #{new_cursor}")
      command = %ReleasePing.Incoming.Commands.AdjustCursor{
        uuid: UUID.uuid4(),
        github_uuid: github_endpoint.uuid,
        software_uuid: UUID.binary_to_string!(erlang_uuid),
        repo_owner: "erlang",
        repo_name: "otp",
        type: :tags,
        cursor: new_cursor
      }

      ReleasePing.Router.dispatch(command)
    end
  end
end
