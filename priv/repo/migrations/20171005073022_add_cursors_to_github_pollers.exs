defmodule ReleasePing.Repo.Migrations.AddCursorsToGithubPollers do
  use Ecto.Migration

  def change do
    alter table(:github_release_pollers) do
      add :last_cursor_tags, :text
      add :last_cursor_releases, :text
    end
  end
end
