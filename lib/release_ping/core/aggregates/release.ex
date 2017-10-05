defmodule ReleasePing.Core.Aggregates.Release do
  alias ReleasePing.Core.Aggregates.Release
  alias ReleasePing.Core.Commands.PublishRelease
  alias ReleasePing.Core.Events.ReleasePublished

  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    version_string: String.t,
    release_notes_url: String.t,
    published_at: DateTime.t,
    seen_at: DateTime.t,
    pre_release: boolean,
  }

  defstruct [:uuid, :software_uuid, :name, :version_string, :release_notes_url, :published_at, :seen_at, :pre_release]

  @doc """
  Creates software
  """
  def execute(%Release{uuid: nil}, %PublishRelease{} = publish) do
    if release_exists?(publish) do
      nil
    else
      %ReleasePublished{
        uuid: publish.uuid,
        software_uuid: publish.software_uuid,
        version_string: publish.version_string,
        release_notes_url: publish.release_notes_url,
        github_cursor: publish.github_cursor,
        published_at: publish.published_at,
        seen_at: publish.seen_at,
        pre_release: publish.pre_release,
      }
    end
  end

  # state mutators

  def apply(%Release{} = release, %ReleasePublished{} = published) do
    %Release{release |
      uuid: published.uuid,
      software_uuid: published.software_uuid,
      version_string: published.version_string,
      release_notes_url: published.release_notes_url,
      published_at: published.published_at,
      seen_at: published.seen_at,
      pre_release: published.pre_release,
    }
  end

  defp release_exists?(%{software_uuid: software_uuid, version_string: version_string}) do
    import Ecto.Query, only: [from: 2]

    software_uuid_binary = UUID.string_to_binary!(software_uuid)

    query = from r in "releases",
              where: r.software_uuid == ^software_uuid_binary and r.version_string == ^version_string,
              select: r.uuid

    ReleasePing.Repo.one(query) != nil
  end
end
