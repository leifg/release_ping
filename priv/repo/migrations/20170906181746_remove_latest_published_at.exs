defmodule ReleasePing.Repo.Migrations.AddGithubIndexSoftware do
  use Ecto.Migration

  def change do
    alter table(:github_release_pollers) do
      remove :latest_published_at
    end
  end
end
