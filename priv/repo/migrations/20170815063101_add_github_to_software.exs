defmodule ReleasePing.Repo.Migrations.AddGithubToSoftware do
  use Ecto.Migration

  def change do
    alter table(:software) do
      add :github, :text
    end
  end
end
