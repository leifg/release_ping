defmodule ReleasePing.Incoming.Aggregates.GithubTest do
  alias ReleasePing.Incoming.Aggregates.Github
  alias ReleasePing.Incoming.Commands.ConfigureGithubEndpoint
  alias ReleasePing.Incoming.Commands.PollGithubReleases
  alias ReleasePing.Incoming.Events.GithubEndpointConfigured
  alias ReleasePing.Incoming.Events.NewGithubReleasesFound
  alias ReleasePing.Incoming.Events.GithubApiCalled

  use ReleasePing.AggregateCase, aggregate: Github

  describe "configure github endpoint" do
    test "succeeds when valid" do
      uuid = UUID.uuid4()
      gh_token = "45ec1b65e3ae4ebca6e613ca6266287540679174"
      base_url = "http://api.github.com"

      command = %ConfigureGithubEndpoint{
        uuid: uuid,
        token: gh_token,
        base_url: base_url,
      }

      assert_events command, [
        %GithubEndpointConfigured{
          uuid: uuid,
          token: gh_token,
          base_url: base_url,
        }
      ]
    end
  end

  describe "poll release" do
    setup do
      uuid = UUID.uuid4()

      bypass = Bypass.open

      command = %ConfigureGithubEndpoint{
        uuid: uuid,
        token: "45ec1b65e3ae4ebca6e613ca6266287540679174",
        base_url: "http://localhost:#{bypass.port}",
      }

      {aggregate, _events, _error} = execute(command)
      {:ok, %{aggregate: aggregate, bypass: bypass}}
    end

    @tag :integration
    test "succeeds with valid data", %{aggregate: aggregate, bypass: bypass} do
      Bypass.expect_once bypass, "POST", "/graphql", fn conn ->
        conn
          |> new_releases_connection_with_headers
          |> Plug.Conn.resp(200, new_releases_json())
      end

      github_uuid = aggregate.uuid

      command = %PollGithubReleases{
        github_uuid: github_uuid,
        repo_owner: "elixir-lang",
        repo_name: "elixir",
      }

      assertion_fun = fn(aggregate, events, _error) ->
        [
          %GithubApiCalled{
            github_uuid: ^github_uuid,
            http_method: "post",
            http_status_code: 200,
            content_length: 9125,
            github_request_id: "F8C0:5192:2E5BCD7:7316E87:59A28E64",
            rate_limit_cost: 1,
            rate_limit_total: 5000,
            rate_limit_remaining: 4999,
            rate_limit_reset: "2017-08-27T10:15:57Z",
          },
          %NewGithubReleasesFound{
            github_uuid: ^github_uuid,
            repo_owner: "elixir-lang",
            repo_name: "elixir",
            last_cursor: "Y3Vyc29yOnYyOpHOAAJGkw==",
            payload: payload,
          },
        ] = events

        assert is_map(payload)

        assert aggregate.rate_limit_total == 5000
        assert aggregate.rate_limit_remaining == 4999
        assert aggregate.rate_limit_reset == ~N[2017-08-27 10:15:57]

        assert aggregate.last_cursors == %{{"elixir-lang", "elixir"} => "Y3Vyc29yOnYyOpHOAAJGkw=="}
        assert aggregate.rate_limit_remaining == 4999
        assert aggregate.rate_limit_reset == ~N[2017-08-27 10:15:57]
      end

      assert_events(aggregate, command, assertion_fun)
    end

    defp new_releases_connection_with_headers(conn) do
      conn
        |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
        |> Plug.Conn.put_resp_header("access-control-expose-headers", "ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval")
        |> Plug.Conn.put_resp_header("cache-control", "no-cache")
        |> Plug.Conn.put_resp_header("content-length", "9125")
        |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
        |> Plug.Conn.put_resp_header("content-security-policy", "default-src 'none'")
        |> Plug.Conn.put_resp_header("date", "Sun, 27 Aug 2017 09:18:29 GMT")
        |> Plug.Conn.put_resp_header("server", "GitHub.com")
        |> Plug.Conn.put_resp_header("status", "200 OK")
        |> Plug.Conn.put_resp_header("strict-transport-security", "max-age=31536000; includeSubdomains; preload")
        |> Plug.Conn.put_resp_header("x-accepted-oauth-scopes", "repo")
        |> Plug.Conn.put_resp_header("x-content-type-options", "nosniff")
        |> Plug.Conn.put_resp_header("x-frame-options", "deny")
        |> Plug.Conn.put_resp_header("x-github-media-type", "github.v4; format=json")
        |> Plug.Conn.put_resp_header("x-github-request-id", "F8C0:5192:2E5BCD7:7316E87:59A28E64")
        |> Plug.Conn.put_resp_header("x-oauth-scopes", "")
        |> Plug.Conn.put_resp_header("x-ratelimit-limit", "5000")
        |> Plug.Conn.put_resp_header("x-ratelimit-remaining", "4999")
        |> Plug.Conn.put_resp_header("x-ratelimit-reset", "1503828957")
        |> Plug.Conn.put_resp_header("x-runtime-rack", "0.122454")
        |> Plug.Conn.put_resp_header("x-xss-protection", "1; mode=block")
    end

    defp new_releases_json do
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
end
