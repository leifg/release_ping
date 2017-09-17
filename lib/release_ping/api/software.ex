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
      field :spdx_id
      field :name
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
      published_at: DateTime.t,
    }

    @primary_key {:id, :binary_id, autogenerate: false}

    embedded_schema do
      field :name
      field :major
      field :minor
      field :patch
      field :published_at
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
    embeds_one :latest_version_stable, Version
    embeds_one :latest_version_unstable, Version
    embeds_many :licenses, License

    timestamps()
  end
end
