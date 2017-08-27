defmodule ReleasePing.Incoming.Aggregates.Github do
  alias ReleasePing.Incoming.Commands.ConfigureGithubEndpoint
  alias ReleasePing.Incoming.Commands.PollGithubReleases
  alias ReleasePing.Incoming.Events.GithubEndpointConfigured
  alias ReleasePing.Incoming.Events.GithubApiCalled
  alias ReleasePing.Incoming.Events.NewGithubReleasesFound

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

  def execute(%__MODULE__{}, %ConfigureGithubEndpoint{} = configure) do
    %GithubEndpointConfigured{
      uuid: configure.uuid,
      token: configure.token,
      base_url: configure.base_url,
    }
  end

  def execute(%__MODULE__{} = aggregate, %PollGithubReleases{} = poll) do
    res = ReleasePing.Github.ApiV4.releases(
      aggregate.base_url,
      aggregate.token,
      poll.repo_owner,
      poll.repo_name,
      last_cursor(aggregate, poll.repo_owner, poll.repo_name)
    )

    github_called_api_event = %GithubApiCalled{
      github_uuid: aggregate.uuid,
      http_url: res.url,
      http_method: to_string(res.method),
      http_status_code: res.status,
      content_length: res.headers["content-length"] |> String.to_integer(),
      github_request_id: res.headers["x-github-request-id"],
      rate_limit_cost: 1,
      rate_limit_total: res.headers["x-ratelimit-limit"] |> String.to_integer(),
      rate_limit_remaining: res.headers["x-ratelimit-remaining"] |> String.to_integer(),
      rate_limit_reset: res.headers["x-ratelimit-reset"] |> String.to_integer() |> DateTime.from_unix!() |> DateTime.to_iso8601(),
    }

    new_releases_found_event = %NewGithubReleasesFound{
      github_uuid: aggregate.uuid,
      repo_owner: poll.repo_owner,
      repo_name: poll.repo_name,
      last_cursor: "Y3Vyc29yOnYyOpHOAAJGkw==",
      payload: Poison.decode!(res.body),
    }

    [github_called_api_event, new_releases_found_event]
  end

  def apply(%__MODULE__{} = github, %GithubEndpointConfigured{} = configured) do
    %__MODULE__{github |
      uuid: configured.uuid,
      token: configured.token,
      base_url: configured.base_url,
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
    updated_last_cursors = Map.put(
      github.last_cursors,
      {new_releases.repo_owner, new_releases.repo_name},
      new_releases.last_cursor
    )

    %__MODULE__{github |
      last_cursors: updated_last_cursors,
    }
  end

  defp last_cursor(aggregate, repo_owner, repo_name) do
    aggregate.last_cursors |> Map.get({repo_owner, repo_name})
  end

  defp canned_response do
  end
end
