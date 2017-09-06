defmodule ReleasePing.Repo.Migrations.AddGithubIndexSoftware do
  use Ecto.Migration

  def change do
    create unique_index(:software, [:github])
  end
end
