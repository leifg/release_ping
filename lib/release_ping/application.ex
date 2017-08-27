defmodule ReleasePing.Application do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ReleasePing.Repo, []),

      worker(ReleasePing.Core.Projectors.Software, [], id: :software_projector),
      worker(ReleasePing.Core.Projectors.Release, [], id: :release_projector),
      worker(ReleasePing.Core.Projectors.GithubReleasePoller, [], id: :github_release_poller_projector),

      worker(ReleasePing.Incoming.Projectors.GithubEndpoint, [], id: :github_endpoint_projector),
    ]

    opts = [strategy: :one_for_one, name: ReleasePing.Supervisor]

    Logger.info("Starting Application")

    Supervisor.start_link(children, opts)
  end
end
