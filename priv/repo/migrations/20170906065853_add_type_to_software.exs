defmodule ReleasePing.Repo.Migrations.AddTypeToSoftware do
  use Ecto.Migration
  alias ReleasePing.Enums.SoftwareTypeEnum

  def up do
    SoftwareTypeEnum.create_type()
    alter table(:software) do
      add :type, :software_type
    end
  end

  def down do
    alter table(:software) do
      remove :type
    end
    SoftwareTypeEnum.drop_type()
  end
end
