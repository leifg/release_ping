defmodule ReleasePing.Incoming.Utils.GithubReleases do

  @pre_release_regex ~r/(?:-alpha)|(?:-beta)|(?:-rc)/
  @valid_tag_regex ~r/\d+\.\d+/

  defmodule NewRelease do
    @type t :: %__MODULE__{
      version_string: String.t,
      published_at: String.t,
      release_notes_url: String.t,
      release_notes_content: String.t,
      pre_release: boolean,
    }

    defstruct [:version_string, :published_at, :release_notes_url, :release_notes_content, :pre_release]
  end

  def merge_tags_and_releases(payloads, repo_owner, repo_name) do
    all_tags = payloads
      |> Enum.map(&fetch_tags/1)
      |> List.flatten()
      |> Enum.filter(&filter_tags/1)
      |> reduce_tags(repo_owner, repo_name)

    all_releases = payloads
      |> Enum.map(&fetch_releases/1)
      |> List.flatten()
      |> Enum.filter(&filter_releases/1)
      |> reduce_releases(repo_owner, repo_name)

    all_tags
      |> Map.merge(all_releases)
      |> Map.values()
      |> Enum.sort(fn(r1, r2) -> r1.published_at < r2.published_at end)
  end

  defp fetch_releases(payload), do: fetch_list(payload, "releases")
  defp fetch_tags(payload), do: fetch_list(payload, "tags")

  defp fetch_list(payload, name) do
    payload["data"]["repository"][name]["edges"]
  end

  defp filter_tags(tag) do
    String.match?(tag["node"]["name"], @valid_tag_regex)
  end

  defp filter_releases(release) do
    !release["node"]["isDraft"]
  end

  defp reduce_tags(tags, repo_owner, repo_name) do
    Enum.reduce(tags, %{}, fn(tag, agg) ->
      tag_node = tag["node"]
      tag_name = tag_node["name"]
      tag_target = tag_node["target"]
      Map.put(
        agg,
        tag_node["id"],
        %{
          version_string: tag_name,
          github_cursor: "tags:#{tag["cursor"]}",
          published_at: normalize_date(tag_target["author"]["date"]),
          release_notes_url: nil,
          release_notes_content: tag_target["message"],
          pre_release: pre_release_from_version(tag_name),
        }
      )
    end)
  end

  defp reduce_releases(tags, repo_owner, repo_name) do
    Enum.reduce(tags, %{}, fn(release, agg) ->
      release_node = release["node"]
      tag_name = release_node["tag"]["name"]
      Map.put(
        agg,
        release_node["tag"]["id"],
        %{
          version_string: tag_name,
          github_cursor: "releases:#{release["cursor"]}",
          published_at: normalize_date(release_node["publishedAt"]),
          release_notes_url: release_node["url"],
          release_notes_content: release_node["description"],
          pre_release: release_node["isPrerelease"],
        }
      )
    end)
  end

  defp normalize_date(nil), do: nil
  defp normalize_date(date_input) do
    {:ok, dt, _offset} = DateTime.from_iso8601(date_input)
    DateTime.to_iso8601(dt)
  end

  defp pre_release_from_version(version) do
    String.match?(version, @pre_release_regex)
  end
end
