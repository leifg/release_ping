defmodule ReleasePing.Repo.Migrations.AddSlugToSoftware do
  use Ecto.Migration

  def change do
    alter table(:software) do
      add :slug, :text
    end

    alter table(:api_software) do
      add :slug, :text
    end
  end
end
