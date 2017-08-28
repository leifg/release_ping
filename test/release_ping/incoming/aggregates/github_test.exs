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
        assert [
          %GithubApiCalled{
            github_uuid: ^github_uuid,
            http_method: "post",
            http_status_code: 200,
            content_length: 2362,
            github_request_id: "C35A:2071:642FCB9:CAED084:59A3BAFA",
            rate_limit_cost: 1,
            rate_limit_total: 5000,
            rate_limit_remaining: 4993,
            rate_limit_reset: "2017-08-28T07:27:53Z",
          },
          %NewGithubReleasesFound{
            github_uuid: ^github_uuid,
            repo_owner: "elixir-lang",
            repo_name: "elixir",
            last_cursor: "Y3Vyc29yOnYyOpHOAG0tAw==",
            payload: payload,
          },
        ] = events

        assert is_map(payload)

        assert aggregate.rate_limit_total == 5000
        assert aggregate.rate_limit_remaining == 4993
        assert aggregate.rate_limit_reset == ~N[2017-08-28 07:27:53]

        assert aggregate.last_cursors == %{{"elixir-lang", "elixir"} => "Y3Vyc29yOnYyOpHOAG0tAw=="}
      end

      assert_events(aggregate, command, assertion_fun)
    end

    defp new_releases_connection_with_headers(conn) do
      conn
        |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
        |> Plug.Conn.put_resp_header("access-control-expose-headers", "ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval")
        |> Plug.Conn.put_resp_header("cache-control", "no-cache")
        |> Plug.Conn.put_resp_header("content-encoding", "gzip")
        |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
        |> Plug.Conn.put_resp_header("content-security-policy", "default-src 'none'")
        |> Plug.Conn.put_resp_header("date", "Mon, 28 Aug 2017 06:40:58 GMT")
        |> Plug.Conn.put_resp_header("server", "GitHub.com")
        |> Plug.Conn.put_resp_header("status", "200 OK")
        |> Plug.Conn.put_resp_header("strict-transport-security", "max-age=31536000; includeSubdomains; preload")
        |> Plug.Conn.put_resp_header("x-accepted-oauth-scopes", "repo")
        |> Plug.Conn.put_resp_header("x-content-type-options", "nosniff")
        |> Plug.Conn.put_resp_header("x-frame-options", "deny")
        |> Plug.Conn.put_resp_header("x-github-media-type", "github.v4; format=json")
        |> Plug.Conn.put_resp_header("x-github-request-id", "C35A:2071:642FCB9:CAED084:59A3BAFA")
        |> Plug.Conn.put_resp_header("x-oauth-scopes", "")
        |> Plug.Conn.put_resp_header("x-ratelimit-limit", "5000")
        |> Plug.Conn.put_resp_header("x-ratelimit-remaining", "4993")
        |> Plug.Conn.put_resp_header("x-ratelimit-reset", "1503905273")
        |> Plug.Conn.put_resp_header("x-runtime-rack", "0.053413")
        |> Plug.Conn.put_resp_header("x-xss-protection", "1; mode=block")
    end

    defp new_releases_json do
      """
      {
        "data": {
          "rateLimit": {
            "cost": 1,
            "limit": 5000,
            "nodeCount": 5,
            "remaining": 4993,
            "resetAt": "2017-08-28T07:27:53Z"
          },
          "repository": {
            "releases": {
              "edges": [
                {
                  "node": {
                    "id": "MDc6UmVsZWFzZTY3OTc3MTg=",
                    "name": "",
                    "isDraft": false,
                    "isPrerelease": false,
                    "publishedAt": "2017-06-22T08:43:55Z",
                    "tag": {
                      "name": "v1.4.5"
                    }
                  },
                  "cursor": "Y3Vyc29yOnYyOpHOAGe5lg=="
                },
                {
                  "node": {
                    "id": "MDc6UmVsZWFzZTY4MjczMDU=",
                    "name": "",
                    "isDraft": false,
                    "isPrerelease": true,
                    "publishedAt": "2017-06-25T11:21:53Z",
                    "tag": {
                      "name": "v1.5.0-rc.0"
                    }
                  },
                  "cursor": "Y3Vyc29yOnYyOpHOAGgtKQ=="
                },
                {
                  "node": {
                    "id": "MDc6UmVsZWFzZTcwMTMxNjY=",
                    "name": "",
                    "isDraft": false,
                    "isPrerelease": true,
                    "publishedAt": "2017-07-12T12:54:03Z",
                    "tag": {
                      "name": "v1.5.0-rc.1"
                    }
                  },
                  "cursor": "Y3Vyc29yOnYyOpHOAGsDLg=="
                },
                {
                  "node": {
                    "id": "MDc6UmVsZWFzZTcxMDYzNTg=",
                    "name": "",
                    "isDraft": false,
                    "isPrerelease": true,
                    "publishedAt": "2017-07-20T09:51:04Z",
                    "tag": {
                      "name": "v1.5.0-rc.2"
                    }
                  },
                  "cursor": "Y3Vyc29yOnYyOpHOAGxvNg=="
                },
                {
                  "node": {
                    "id": "MDc6UmVsZWFzZTcxNTQ5NDc=",
                    "name": "",
                    "isDraft": false,
                    "isPrerelease": false,
                    "publishedAt": "2017-07-25T07:27:16Z",
                    "tag": {
                      "name": "v1.5.0"
                    }
                  },
                  "cursor": "Y3Vyc29yOnYyOpHOAG0tAw=="
                }
              ],
              "pageInfo": {
                "endCursor": "Y3Vyc29yOnYyOpHOAG0tAw==",
                "hasNextPage": true,
                "hasPreviousPage": true,
                "startCursor": "Y3Vyc29yOnYyOpHOAGe5lg=="
              }
            }
          }
        }
      }
      """
    end
  end
end
