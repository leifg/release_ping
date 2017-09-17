defmodule ReleasePing.Repo.Migrations.CreateApiSoftware do
  use Ecto.Migration

  def change do
    create table(:api_software, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :stream_version, :integer, default: 0
      add :name, :text
      add :website, :text
      add :latest_version_stable, :map
      add :latest_version_unstable, :map
      add :licenses, {:array, :map}, default: []

      timestamps()
    end
  end
end
