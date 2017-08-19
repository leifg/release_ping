defmodule ReleasePing.Repo.Migrations.CreateGithubReleasePollers do
  use Ecto.Migration

  def change do
    create table(:github_release_pollers, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :stream_version, :integer, default: 0
      add :software_uuid, :uuid
      add :repository, :text
      add :latest_published_at, :utc_datetime

      timestamps()
    end

    create unique_index(:github_release_pollers, [:uuid])
    create unique_index(:github_release_pollers, [:software_uuid])
  end
end
