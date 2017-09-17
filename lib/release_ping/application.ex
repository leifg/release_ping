defmodule ReleasePing.Application do
  use Application

  require Logger

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(ReleasePing.Repo, []),
      supervisor(ReleasePingWeb.Endpoint, []),

      worker(ReleasePing.Validation.Unique, []),

      worker(ReleasePing.Worflows.PublishReleases, [[start_from: :origin]], id: :publish_releases_workflow),

      worker(ReleasePing.Core.Projectors.Software, [], id: :software_projector),
      worker(ReleasePing.Core.Projectors.Release, [], id: :release_projector),
      worker(ReleasePing.Core.Projectors.GithubReleasePoller, [], id: :github_release_poller_projector),
    ]


    Logger.info("Starting Application")

    opts = [strategy: :one_for_one, name: ReleasePing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ReleasePingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
