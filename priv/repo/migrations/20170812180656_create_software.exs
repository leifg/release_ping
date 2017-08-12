defmodule ReleasePing.Repo.Migrations.CreateSoftware do
  use Ecto.Migration

  def change do
    create table(:software, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :stream_version, :integer, default: 0
      add :name, :text
      add :website, :text
      add :licenses, {:array, :text}

      timestamps()
    end

    create unique_index(:software, [:uuid])
    create index(:software, [:name])
  end
end
