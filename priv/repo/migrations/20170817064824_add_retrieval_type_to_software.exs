defmodule ReleasePing.Repo.Migrations.AddRetrievalTypeToSoftware do
  use Ecto.Migration

  def change do
    alter table(:software) do
      add :release_retrieval, :text
    end
  end
end
