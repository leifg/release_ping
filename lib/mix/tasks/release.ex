defmodule ReleasePing.ReleaseTasks do
  @start_apps [
    :postgrex,
    :ecto,
  ]

  @apps [
    :release_ping
  ]

  @repo ReleasePing.Repo

  def migrate do
    start_and_stop(fn ->
      IO.puts "Starting repo.."
      @repo.start_link(pool_size: 1)

      IO.puts "Running migrations"
      Enum.each(@apps, &run_migrations_for/1)
    end)
  end

  def create_readstore do
    start_and_stop(fn ->
      @repo.__adapter__.storage_up(@repo.config)
    end)
  end

  def create_writestore do
    config = EventStore.Config.parse(Application.get_env(:eventstore, EventStore.Storage))
    case EventStore.Storage.Database.create(config) do
      :ok -> initialize_storage(config)
      {:error, :already_up} -> IO.puts "The EventStore database already exists."
    end
  end

  defp initialize_storage(config) do
    {:ok, conn} = Postgrex.start_link(config)

    :ok = EventStore.Storage.Initializer.run!(conn)
    IO.puts("Eventstore initialized")
  end

  defp priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp start_and_stop(fun) do
    IO.puts "Loading App.."
    :ok = Application.load(:release_ping)

    IO.puts "Starting dependencies.."
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    IO.puts "Calling Callback"
    fun.()

    IO.puts "Success!"
    :init.stop()
  end

  defp run_migrations_for(app) do
    IO.puts "Running migrations for #{app}"
    Ecto.Migrator.run(@repo, migrations_path(app), :up, all: true)
  end

  defp migrations_path(app), do: Path.join([priv_dir(app), "repo", "migrations"])
end
