defmodule ReleasePing.Core do
  alias ReleasePing.Core.Commands.{AddSoftware, PublishRelease}
  alias ReleasePing.Core.{Release, GithubReleasePoller, Software}
  alias ReleasePing.{Router, Wait, Repo}

  @doc """
  Add Software
  """
  @spec add_software(map) :: Software.t | {:error, any}
  def add_software(attrs) do
    uuid = UUID.uuid4()

    %AddSoftware{
      uuid: uuid,
      name: attrs[:name],
      type: attrs[:type],
      website: attrs[:website],
      github: attrs[:github],
      licenses: attrs[:licenses],
      release_retrieval: attrs[:release_retrieval],
    }
      |> Router.dispatch()
      |> case do
        :ok -> Wait.until(fn -> Repo.get(Software, uuid) end)
        reply -> reply
      end
  end

  @spec software_by_github(String.t, String.t) :: Software.t | nil
  def software_by_github(repo_owner, repo_name) do
    case repo_owner |> Software.by_github_query(repo_name) |> Repo.one do
      nil -> {:error, :not_found}
      software -> {:ok, software}
    end
  end

  def all_software() do
    Repo.all(Software)
  end

  @doc """
  Publish a Release
  """
  @spec publish_release(map) :: Release.t | {:error, any}
  def publish_release(attrs) do
    uuid = UUID.uuid4()

    %PublishRelease{
      uuid: uuid,
      software_uuid: attrs[:software_uuid],
      version_string: attrs[:version_string],
      release_notes_url: attrs[:release_notes_url],
      published_at: attrs[:published_at],
      seen_at: attrs[:seen_at],
      pre_release: attrs[:pre_release],
    }
      |> Router.dispatch()
      |> case do
        :ok -> Wait.until(fn -> Repo.get(Release, uuid) end)
        reply -> reply
      end
  end

  @doc """
  Get all existing github pollers
  """
  @spec github_release_pollers :: any
  def github_release_pollers do
    Repo.all(GithubReleasePoller)
  end
end
