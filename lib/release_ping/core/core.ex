defmodule ReleasePing.Core do
  alias ReleasePing.Core.Commands.{AddSoftware, ChangeLicenses, PublishRelease}
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
      version_scheme: attrs[:version_scheme],
      website: attrs[:website],
      github: attrs[:github],
      licenses: attrs[:licenses],
      release_retrieval: attrs[:release_retrieval],
    }
      |> Router.dispatch()
      |> case do
        :ok -> Wait.until(fn -> software_by_uuid(uuid) end)
        reply -> reply
      end
  end

  def change_licenses(%{software_uuid: software_uuid, spdx_ids: license_ids}) do
    Router.dispatch(%ChangeLicenses{
      uuid: UUID.uuid4(),
      software_uuid: software_uuid,
      licenses: license_ids,
    })
  end

  def software_by_uuid(uuid) do
    case Repo.get(Software, uuid) do
      nil -> nil
      software -> Map.put(software, :version_scheme, compile_regex!(software.version_scheme))
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

  defp compile_regex!(nil), do: nil
  defp compile_regex!(regex_string), do: Regex.compile!(regex_string)
end
