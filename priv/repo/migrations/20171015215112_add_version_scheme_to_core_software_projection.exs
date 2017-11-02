defmodule ReleasePing.Repo.Migrations.AddVersionSchemeToCoreSoftwareProjection do
  use Ecto.Migration
  alias Commanded.EventStore.Adapters.EventStore

  def up do
    execute "DELETE FROM projection_versions WHERE projection_name = 'Core.Projectors.Software';"
    execute "DELETE FROM software;"
    Application.ensure_all_started(:postgrex)
    Application.ensure_all_started(:eventstore)
    EventStore.subscribe_to_all_streams("Core.Projectors.Software", self())
    EventStore.unsubscribe_from_all_streams("Core.Projectors.Software")

    alter table(:software) do
      add :version_scheme, :text
      add :release_notes_url_template, :text
    end
  end

  def down do
    alter table(:software) do
      remove :version_scheme
      remove :release_notes_url_template
    end
  end
end
