defmodule ReleasePing.Repo.Migrations.UseEnumForReleaseRetrieval do
  use Ecto.Migration
  alias ReleasePing.Enums.ReleaseRetrievalEnum

  def up do
    ReleaseRetrievalEnum.create_type()

    alter table(:software) do
      remove :release_retrieval
    end

    flush()

    alter table(:software) do
      add :release_retrieval, :release_retrieval
    end
  end

  def down do
    alter table(:software) do
      remove :release_retrieval
    end

    flush()

    alter table(:software) do
      add :release_retrieval, :text
    end

    ReleaseRetrievalEnum.drop_type()
  end
end
