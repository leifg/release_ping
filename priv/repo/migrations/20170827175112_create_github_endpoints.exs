defmodule ReleasePing.Repo.Migrations.CreateGithubEndpoints do
  use Ecto.Migration

  def change do
    create table(:github_endpoints, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :stream_version, :integer, default: 0
      add :rate_limit_total, :integer
      add :rate_limit_remaining, :integer
      add :rate_limit_reset, :utc_datetime

      timestamps()
    end

    create unique_index(:github_endpoints, [:uuid])
  end
end
