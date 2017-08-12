defmodule ReleasePing.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ReleasePing.Repo, []),

      worker(ReleasePing.Core.Projectors.Software, [], id: :software_projector),
    ]

    opts = [strategy: :one_for_one, name: ReleasePing.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
