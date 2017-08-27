defmodule ReleasePing.Storage do
  @doc """
  Clear the event store and read store databases
  """
  def reset! do
    :ok = Application.stop(:release_ping)
    :ok = Application.stop(:commanded)
    :ok = Application.stop(:eventstore)

    reset_eventstore()
    reset_readstore()

    {:ok, _} = Application.ensure_all_started(:release_ping)
  end

  defp reset_eventstore do
    eventstore_config = Application.get_env(:eventstore, EventStore.Storage)

    {:ok, conn} = Postgrex.start_link(eventstore_config)

    EventStore.Storage.Initializer.reset!(conn)
  end

  defp reset_readstore do
    readstore_config = Application.get_env(:release_ping, ReleasePing.Repo)

    {:ok, conn} = Postgrex.start_link(readstore_config)

    Postgrex.query!(conn, truncate_readstore_tables(), [])
  end

  defp truncate_readstore_tables do
"""
TRUNCATE TABLE
  software,
  releases,
  github_release_pollers,
  github_endpoints,
  projection_versions
RESTART IDENTITY;
"""
  end
end
