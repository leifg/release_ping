defmodule ReleasePing.Repo.Migrations.CreateActiveSubscriptions do
  use Ecto.Migration

  def change do
    create table(:active_subscriptions, primary_key: false) do
      add :uuid, :uuid
      add :stream_version, :integer, default: 0
      add :name, :text
      add :callback_url, :text
      add :priority, :integer
      add :topic, :string
      add :type, :software_type
      add :software_uuid, :uuid

      timestamps()
    end

    create unique_index(:active_subscriptions, [:uuid, :topic, :type])
    create index(:active_subscriptions, [:priority])
    create index(:active_subscriptions, [:software_uuid])
  end
end
