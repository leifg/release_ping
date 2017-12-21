defmodule ReleasePing.Repo.Migrations.ResetApiSoftwareForVersionString do
  use Ecto.Migration

  def change do
    execute "DELETE FROM projection_versions WHERE projection_name = 'Api.Projectors.Software';"
    execute "DELETE FROM api_software;"
    Application.ensure_all_started(:postgrex)
    Application.ensure_all_started(:eventstore)
    EventStore.subscribe_to_all_streams("Api.Projectors.Software", self())
    EventStore.unsubscribe_from_all_streams("Api.Projectors.Software")
  end
end
