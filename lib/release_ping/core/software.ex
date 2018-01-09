defmodule ReleasePing.Core.Software do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]

  @type t :: %__MODULE__{
          uuid: String.t(),
          name: String.t(),
          type: String.t(),
          slug: String.t(),
          website: String.t(),
          github: String.t(),
          licenses: [String.t()],
          release_retrieval: ReleasePing.Enums.release_retrieval(),
          version_scheme: Regex.t(),
          release_notes_url_template: String.t()
        }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "software" do
    field(:stream_version, :integer)
    field(:name, :string)
    field(:slug, :string)
    field(:type, ReleasePing.Enums.SoftwareTypeEnum)
    field(:website, :string)
    field(:github, :string)
    field(:licenses, {:array, :string})
    field(:release_retrieval, ReleasePing.Enums.ReleaseRetrievalEnum)
    field(:version_scheme, :string)
    field(:release_notes_url_template, :string)

    timestamps()
  end

  def by_github_query(repo_owner, repo_name) do
    from(
      s in ReleasePing.Core.Software,
      where: s.github == ^"#{repo_owner}/#{repo_name}",
      select: s
    )
  end
end
