defmodule ReleasePing.Repo.Migrations.CreateRelease do
  use Ecto.Migration

  def change do
    create table(:release, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :stream_version, :integer, default: 0
      add :software_uuid, :uuid
      add :version_string, :text
      add :major_version, :integer
      add :minor_version, :integer
      add :patch_version, :integer
      add :pre_release, :boolean
      add :release_notes_url, :text
      add :published_at, :utc_datetime
      add :seen_at, :utc_datetime

      timestamps()
    end

    create unique_index(:release, [:uuid])
    create index(:release, [:software_uuid])
  end
end
