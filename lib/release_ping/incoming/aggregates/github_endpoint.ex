defmodule ReleasePing.Incoming.Aggregates.GithubEndpoint do
  alias ReleasePing.Incoming.Commands.ConfigureGithubEndpoint
  alias ReleasePing.Incoming.Commands.PollGithubReleases
  alias ReleasePing.Incoming.Events.GithubEndpointConfigured
  alias ReleasePing.Incoming.Events.GithubApiCalled
  alias ReleasePing.Incoming.Events.NewGithubReleasesFound

  alias ReleasePing.Github.ApiV4
  alias ReleasePing.Github.ReleaseRequest

  @type t :: %__MODULE__{
    uuid: String.t,
    token: String.t,
    base_url: String.t,
    last_cursors: map,
    rate_limit_total: non_neg_integer,
    rate_limit_remaining: non_neg_integer,
    rate_limit_reset: NaiveDateTime.t,
  }

  defstruct [
    uuid: nil,
    token: nil,
    base_url: nil,
    last_cursors: %{},
    rate_limit_total: nil,
    rate_limit_remaining: nil,
    rate_limit_reset: nil,
  ]

  def execute(%__MODULE__{uuid: nil}, %ConfigureGithubEndpoint{} = configure) do
    res = ApiV4.rate_limit(configure.base_url, configure.token)

    payload = Poison.decode!(res.body)
    rate_limit = payload["resources"]["graphql"]

    %GithubEndpointConfigured{
      uuid: configure.uuid,
      token: configure.token,
      base_url: configure.base_url,
      rate_limit_total: rate_limit["limit"],
      rate_limit_remaining: rate_limit["remaining"],
      rate_limit_reset: rate_limit["reset"] |> DateTime.from_unix!() |> DateTime.to_iso8601(),
    }
  end
  def execute(%__MODULE__{}, %ConfigureGithubEndpoint{}), do: {:error, :github_endpoint_already_exists}

  def execute(%__MODULE__{} = aggregate, %PollGithubReleases{} = poll) do
    aggregate
      |> fetch_releases(
        poll,
        last_cursors(aggregate, poll.repo_owner, poll.repo_name),
        []
      )
      |> Enum.reverse()
      |> build_github_release_events(poll)
  end

  def apply(%__MODULE__{} = github, %GithubEndpointConfigured{} = configured) do
    %__MODULE__{github |
      uuid: configured.uuid,
      token: configured.token,
      base_url: configured.base_url,
      rate_limit_total: configured.rate_limit_total,
      rate_limit_remaining: configured.rate_limit_remaining,
      rate_limit_reset: NaiveDateTime.from_iso8601!(configured.rate_limit_reset),
    }
  end

  def apply(%__MODULE__{} = github, %GithubApiCalled{} = api_called) do
    %__MODULE__{github |
      rate_limit_total: api_called.rate_limit_total,
      rate_limit_remaining: api_called.rate_limit_remaining,
      rate_limit_reset: NaiveDateTime.from_iso8601!(api_called.rate_limit_reset),
    }
  end

  def apply(%__MODULE__{} = github, %NewGithubReleasesFound{} = new_releases) do
    updated_last_cursors = Map.merge(
      last_cursors(github, new_releases.repo_owner, new_releases.repo_name),
      %{
        tags: new_releases.last_cursor_tags,
        releases: new_releases.last_cursor_releases,
      },
      &update_when_present/3
    )

    %__MODULE__{github |
      last_cursors: Map.put(
        github.last_cursors,
        {new_releases.repo_owner, new_releases.repo_name},
        updated_last_cursors
      )
    }
  end

  defp last_cursors(aggregate, repo_owner, repo_name) do
    aggregate.last_cursors |> Map.get({repo_owner, repo_name}, %{tags: nil, releases: nil})
  end

  defp fetch_releases(aggregate, poll_comand, %{tags: last_cursor_tags, releases: last_cursor_releases}, agg) do
    res = ApiV4.releases(
      aggregate.base_url,
      aggregate.token,
      %ReleaseRequest{
        repo_owner: poll_comand.repo_owner,
        repo_name: poll_comand.repo_name,
        last_cursor_tags: last_cursor_tags,
        last_cursor_releases: last_cursor_releases,
      }
    )

    payload = Poison.decode!(res.body)

    releases_page_info = payload["data"]["repository"]["releases"]["pageInfo"]
    tags_page_info = payload["data"]["repository"]["tags"]["pageInfo"]
    releases_next_cursor = releases_page_info["endCursor"] || last_cursor_releases
    tags_next_cursor = tags_page_info["endCursor"] || last_cursor_tags

    batch = [%Tesla.Env{res | body: payload} | agg]

    if releases_page_info["hasNextPage"] || tags_page_info["hasNextPage"] do
      fetch_releases(aggregate, poll_comand, %{tags: tags_next_cursor, releases: releases_next_cursor}, batch)
    else
      batch
    end
  end

  defp build_github_release_events(api_returns, poll_command) do
    github_api_called_events = Enum.map(api_returns, fn (ar) ->
      %GithubApiCalled{
        uuid: UUID.uuid4(),
        github_uuid: poll_command.github_uuid,
        http_url: ar.url,
        http_method: to_string(ar.method),
        http_status_code: ar.status,
        content_length: ar.headers["content-length"] |> String.to_integer(),
        github_request_id: ar.headers["x-github-request-id"],
        rate_limit_cost: ar.body["data"]["rateLimit"]["cost"],
        rate_limit_total: ar.headers["x-ratelimit-limit"] |> String.to_integer(),
        rate_limit_remaining: ar.headers["x-ratelimit-remaining"] |> String.to_integer(),
        rate_limit_reset: ar.headers["x-ratelimit-reset"] |> String.to_integer() |> DateTime.from_unix!() |> DateTime.to_iso8601(),
      }
    end)

    initial_event = %NewGithubReleasesFound{
      uuid: UUID.uuid4(),
      github_uuid: poll_command.github_uuid,
      repo_owner: poll_command.repo_owner,
      repo_name: poll_command.repo_name,
      seen_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      last_cursor_releases: nil,
      last_cursor_tags: nil,
      payload: []
    }

    github_release_found_event = if api_returns_empty?(api_returns) do
      []
    else
      api_returns |> Enum.reduce(initial_event, fn(ar, acc) ->
        acc
          |> Map.merge(%{
            last_cursor_releases: ar.body["data"]["repository"]["releases"]["pageInfo"]["endCursor"],
            last_cursor_tags: ar.body["data"]["repository"]["tags"]["pageInfo"]["endCursor"]},
            &update_when_present/3
          )
          |> Map.merge(%{
            payload: ar.body,
          },
          fn(_key, old_val, new_val) -> old_val ++ [new_val] end)
        end)
        |> List.wrap()
    end

    github_api_called_events ++ github_release_found_event
  end

  defp api_returns_empty?([%{body: body}]) do
    Enum.empty?(
      body["data"]["repository"]["releases"]["edges"] ++ body["data"]["repository"]["tags"]["edges"]
    )
  end
  defp api_returns_empty?(_), do: false

  defp update_when_present(_key, old_val, nil), do: old_val
  defp update_when_present(_key, _old_val, new_val), do: new_val
end
