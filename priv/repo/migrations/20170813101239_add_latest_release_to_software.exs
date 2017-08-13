defmodule ReleasePing.Repo.Migrations.AddLatestReleaseToSoftware do
  use Ecto.Migration

  def change do
    alter table(:software) do
      add :latest_release_uuid, :uuid
    end
  end
end
