defmodule ReleasePing.Api.Software do
  use Ecto.Schema

  alias ReleasePing.Api.Software.{License, Version}

  defmodule License do
    use Ecto.Schema

    @type t :: %__MODULE__{
      spdx_id: String.t,
      name: String.t,
    }

    @primary_key false

    embedded_schema do
      field :spdx_id, :string
      field :name, :string
    end
  end

  defmodule Version do
    use Ecto.Schema

    @type t :: %__MODULE__{
      id: String.t,
      name: String.t,
      major: integer,
      minor: integer,
      patch: integer,
      release_notes_url: String.t,
      published_at: DateTime.t,
    }

    @type compare_result :: :lt | :gt | :eq

    @primary_key {:id, :binary_id, autogenerate: false}

    embedded_schema do
      field :name, :string
      field :major, :integer
      field :minor, :integer
      field :patch, :integer
      field :release_notes_url, :string
      field :published_at, :utc_datetime
    end
  end

  @type t :: %__MODULE__{
    id: String.t,
    name: String.t,
    website: String.t,
    latest_version_stable: Version.t,
    latest_version_unstable: Version.t,
    licenses: [License.t],
  }

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "api_software" do
    field :stream_version, :integer
    field :name, :string
    field :website, :string
    embeds_one :latest_version_stable, Version, on_replace: :delete
    embeds_one :latest_version_unstable, Version, on_replace: :delete
    embeds_many :licenses, License, on_replace: :delete

    timestamps()
  end
end
