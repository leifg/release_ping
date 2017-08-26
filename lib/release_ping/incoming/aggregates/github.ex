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
    rate_limit_reset: DateTime.t,
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
    res = external_call_github_releases(aggregate.base_url, aggregate.token, last_cursor(aggregate, poll.repo_owner, poll.repo_name))

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

  def apply(%__MODULE__{} = github, %GithubApiCalled{} = api_called) do
    {:ok, datetime_reset, 0} = DateTime.from_iso8601(api_called.rate_limit_reset)
    %__MODULE__{github |
      rate_limit_total: api_called.rate_limit_total,
      rate_limit_remaining: api_called.rate_limit_total,
      rate_limit_reset: datetime_reset,
    }
  end

  def apply(%__MODULE__{} = github, %GithubEndpointConfigured{} = configured) do
    %__MODULE__{github |
      uuid: configured.uuid,
      token: configured.token,
      base_url: configured.base_url,
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

  defp external_call_github_releases(_url, _token, _last_cursor) do
    %Tesla.Env{
      url: "https://api.github.com/graphql",
      method: :post,
      status: 200,
      headers: %{
        "access-control-allow-origin" => "*",
        "access-control-expose-headers" => "ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval",
        "cache-control" => "no-cache", "content-length" => "9125",
        "content-security-policy" => "default-src 'none'",
        "content-type" => "application/json; charset=utf-8",
        "date" => "Sun, 27 Aug 2017 09:18:29 GMT",
        "server" => "GitHub.com",
        "status" => "200 OK",
        "strict-transport-security" => "max-age=31536000; includeSubdomains; preload",
        "x-accepted-oauth-scopes" => "repo",
        "x-content-type-options" => "nosniff",
        "x-frame-options" => "deny",
        "x-github-media-type" => "github.v4; format=json",
        "x-github-request-id" => "F8C0:5192:2E5BCD7:7316E87:59A28E64",
        "x-oauth-scopes" => "",
        "x-ratelimit-limit" => "5000",
        "x-ratelimit-remaining" => "4999",
        "x-ratelimit-reset" => "1503828957",
        "x-runtime-rack" => "0.122454",
        "x-xss-protection" => "1; mode=block"
      },
      body: canned_response(),
    }
  end

  defp last_cursor(aggregate, repo_owner, repo_name) do
    aggregate.last_cursors |> Map.get({repo_owner, repo_name})
  end

  defp canned_response do
  """
    {
      "data": {
        "rateLimit": {
          "cost": 1,
          "limit": 5000,
          "nodeCount": 10,
          "remaining": 4999,
          "resetAt": "2017-08-27T10:15:57Z"
        },
        "repository": {
          "releases": {
            "edges": [
              {
                "node": {
                  "isDraft": false,
                  "id": "MDc6UmVsZWFzZTk5NDk=",
                  "name": "v0.10.0",
                  "tag": {
                    "name": "v0.10.0"
                  }
                },
                "cursor": "Y3Vyc29yOnYyOpHNJt0="
              },
              {
                "node": {
                  "isDraft": false,
                  "id": "MDc6UmVsZWFzZTIwNDk1",
                  "name": "v0.10.1",
                  "tag": {
                    "name": "v0.10.1"
                  }
                },
                "cursor": "Y3Vyc29yOnYyOpHNUA8="
              },
              {
                "node": {
                  "isDraft": false,
                  "id": "MDc6UmVsZWFzZTM3OTk2",
                  "name": "v0.10.2",
                  "tag": {
                    "name": "v0.10.2"
                  }
                },
                "cursor": "Y3Vyc29yOnYyOpHNlGw="
              },
              {
                "node": {
                  "isDraft": false,
                  "id": "MDc6UmVsZWFzZTU3NTg0",
                  "name": "v0.10.3",
                  "tag": {
                    "name": "v0.10.3"
                  }
                },
                "cursor": "Y3Vyc29yOnYyOpHN4PA="
              },
              {
                "node": {
                  "isDraft": false,
                  "id": "MDc6UmVsZWFzZTgyNzk4",
                  "name": "v0.11.0",
                  "tag": {
                    "name": "v0.11.0"
                  }
                },
                "cursor": "Y3Vyc29yOnYyOpHOAAFDbg=="
              },
              {
                "node": {
                  "isDraft": false,
                  "id": "MDc6UmVsZWFzZTg3NDIx",
                  "name": "v0.11.1",
                  "tag": {
                    "name": "v0.11.1"
                  }
                },
                "cursor": "Y3Vyc29yOnYyOpHOAAFVfQ=="
              },
              {
                "node": {
                  "isDraft": false,
                  "id": "MDc6UmVsZWFzZTkzNDE4",
                  "name": "v0.11.2",
                  "tag": {
                    "name": "v0.11.2"
                  }
                },
                "cursor": "Y3Vyc29yOnYyOpHOAAFs6g=="
              },
              {
                "node": {
                  "isDraft": false,
                  "id": "MDc6UmVsZWFzZTEyMjczNg==",
                  "name": "v0.12.0",
                  "tag": {
                    "name": "v0.12.0"
                  }
                },
                "cursor": "Y3Vyc29yOnYyOpHOAAHfcA=="
              },
              {
                "node": {
                  "isDraft": false,
                  "id": "MDc6UmVsZWFzZTEzNzQwNw==",
                  "name": "v0.12.1",
                  "tag": {
                    "name": "v0.12.1"
                  }
                },
                "cursor": "Y3Vyc29yOnYyOpHOAAIYvw=="
              },
              {
                "node": {
                  "isDraft": false,
                  "id": "MDc6UmVsZWFzZTE0OTEzOQ==",
                  "name": "v0.12.2",
                  "tag": {
                    "name": "v0.12.2"
                  }
                },
                "cursor": "Y3Vyc29yOnYyOpHOAAJGkw=="
              }
            ],
            "pageInfo": {
              "endCursor": "Y3Vyc29yOnYyOpHOAAJGkw==",
              "hasNextPage": true,
              "hasPreviousPage": false,
              "startCursor": "Y3Vyc29yOnYyOpHNJt0="
            }
          }
        }
      }
    }
  """
  end
end
