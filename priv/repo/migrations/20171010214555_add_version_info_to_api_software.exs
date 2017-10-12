defmodule ReleasePing.Repo.Migrations.AddVersionInfoToApiSoftware do
  use Ecto.Migration

  def up do
    execute "DELETE FROM projection_versions WHERE projection_name = 'Api.Projectors.Software';"
    execute "DELETE FROM api_software;"
    Application.ensure_all_started(:postgrex)
    Application.ensure_all_started(:eventstore)
    Commanded.EventStore.Adapters.EventStore.subscribe_to_all_streams("Api.Projectors.Software", self())
    Commanded.EventStore.Adapters.EventStore.unsubscribe_from_all_streams("Api.Projectors.Software")
  end

  def down, do: :ok
end
