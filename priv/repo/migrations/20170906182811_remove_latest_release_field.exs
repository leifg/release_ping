defmodule ReleasePing.Repo.Migrations.RemoveLatestReleaseField do
  use Ecto.Migration

  def change do
    alter table(:software) do
      remove :latest_release_uuid
    end
  end
end
