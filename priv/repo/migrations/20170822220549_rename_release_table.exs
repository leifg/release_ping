defmodule ReleasePing.Repo.Migrations.RenameReleaseTable do
  use Ecto.Migration

  def change do
    rename table(:release), to: table(:releases)
  end
end
