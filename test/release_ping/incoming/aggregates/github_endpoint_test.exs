defmodule ReleasePing.Incoming.Aggregates.GithubEndpointTest do
  alias ReleasePing.Incoming.Aggregates.GithubEndpoint
  alias ReleasePing.Incoming.Commands.ConfigureGithubEndpoint
  alias ReleasePing.Incoming.Commands.PollGithubReleases
  alias ReleasePing.Incoming.Events.GithubEndpointConfigured
  alias ReleasePing.Incoming.Events.NewGithubReleasesFound
  alias ReleasePing.Incoming.Events.GithubApiCalled

  use ReleasePing.AggregateCase, aggregate: GithubEndpoint

  describe "configure github endpoint" do
    setup do
      bypass = Bypass.open

      {:ok, %{bypass: bypass}}
    end

    test "succeeds when valid", %{bypass: bypass} do
      Bypass.expect bypass, "GET", "/rate_limit", fn conn ->
        conn
          |> rate_limit_headers()
          |> Plug.Conn.resp(200, rate_limit_json())
      end

      uuid = UUID.uuid4()
      gh_token = "45ec1b65e3ae4ebca6e613ca6266287540679174"
      base_url = "http://localhost:#{bypass.port}"

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
          rate_limit_total: 5000,
          rate_limit_remaining: 4999,
          rate_limit_reset: "2017-08-28T22:44:04Z",
        }
      ]
    end
  end

  describe "poll release" do
    @cursor_regex ~r/after:\s*(?<cursor>["a-zA-Z0-9=\\]+)/

    setup do
      uuid = UUID.uuid4()

      bypass = Bypass.open

      event = %GithubEndpointConfigured{
        uuid: uuid,
        token: "45ec1b65e3ae4ebca6e613ca6266287540679174",
        base_url: "http://localhost:#{bypass.port}",
        rate_limit_total: 5000,
        rate_limit_remaining: 5000,
        rate_limit_reset: "2017-08-28T22:44:04Z",
      }

      aggregate = evolve(event)

      {:ok, %{aggregate: aggregate, bypass: bypass}}
    end

    @tag :integration
    test "succeeds with new releases", %{aggregate: aggregate, bypass: bypass} do
      Bypass.expect bypass, "POST", "/graphql", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        page = case Regex.named_captures(@cursor_regex, body) do
          %{"cursor" => "null"} -> 1
          _ -> 2
        end

        conn
          |> new_releases_connection_with_headers(page)
          |> Plug.Conn.resp(200, new_releases_json(page))
      end

      github_uuid = aggregate.uuid

      command = %PollGithubReleases{
        github_uuid: github_uuid,
        repo_owner: "elixir-lang",
        repo_name: "elixir",
      }

      assertion_fun = fn(inner_aggregate, events, _error) ->
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
            payload: payload_1,
          },
          %GithubApiCalled{
            github_uuid: ^github_uuid,
            http_method: "post",
            http_status_code: 200,
            content_length: 835,
            github_request_id: "DE90:2070:4B14F0C:9E475BE:59A3C08E",
            rate_limit_cost: 1,
            rate_limit_total: 5000,
            rate_limit_remaining: 4992,
            rate_limit_reset: "2017-08-28T07:27:53Z",
          },
          %NewGithubReleasesFound{
            github_uuid: ^github_uuid,
            repo_owner: "elixir-lang",
            repo_name: "elixir",
            last_cursor: "Y3Vyc29yOnYyOpHOAG6Jng==",
            payload: payload_2,
          },
        ] = events

        assert is_list(payload_1)
        assert is_list(payload_2)

        assert inner_aggregate.rate_limit_total == 5000
        assert inner_aggregate.rate_limit_remaining == 4992
        assert inner_aggregate.rate_limit_reset == ~N[2017-08-28 07:27:53]

        assert inner_aggregate.last_cursors == %{{"elixir-lang", "elixir"} => "Y3Vyc29yOnYyOpHOAG6Jng=="}
      end

      assert_events(aggregate, command, assertion_fun)
    end

    test "suceeds without new releases", %{aggregate: aggregate, bypass: bypass} do
      Bypass.expect bypass, "POST", "/graphql", fn conn ->
        conn
          |> no_new_releases_connection_with_headers()
          |> Plug.Conn.resp(200, no_new_releases_json())
      end

      github_uuid = aggregate.uuid

      command = %PollGithubReleases{
        github_uuid: github_uuid,
        repo_owner: "elixir-lang",
        repo_name: "elixir",
      }

      assertion_fun = fn(_aggregate, events, _error) ->
        assert [
          %GithubApiCalled{
            github_uuid: ^github_uuid,
            http_method: "post",
            http_status_code: 200,
            content_length: 404,
            github_request_id: "C16E:2071:6FF1EE4:E38B049:59A485F3",
            rate_limit_cost: 1,
            rate_limit_total: 5000,
            rate_limit_remaining: 4999,
            rate_limit_reset: "2017-08-28T22:06:59Z",
          },
        ] = events
      end

      assert_events(aggregate, command, assertion_fun)
    end

    defp rate_limit_headers(conn) do
      conn
        |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
        |> Plug.Conn.put_resp_header("access-control-expose-headers", "ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval")
        |> Plug.Conn.put_resp_header("cache-control", "no-cache")
        |> Plug.Conn.put_resp_header("content-encoding", "gzip")
        |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
        |> Plug.Conn.put_resp_header("content-security-policy", "default-src 'none'")
        |> Plug.Conn.put_resp_header("date", "Mon, 28 Aug 2017 22:44:52 GMT")
        |> Plug.Conn.put_resp_header("server", "GitHub.com")
        |> Plug.Conn.put_resp_header("status", "200 OK")
        |> Plug.Conn.put_resp_header("strict-transport-security", "max-age=31536000; includeSubdomains; preload")
        |> Plug.Conn.put_resp_header("x-accepted-oauth-scopes", "repo")
        |> Plug.Conn.put_resp_header("x-content-type-options", "nosniff")
        |> Plug.Conn.put_resp_header("x-frame-options", "deny")
        |> Plug.Conn.put_resp_header("x-github-media-type", "github.v4; format=json")
        |> Plug.Conn.put_resp_header("x-github-request-id", "CBBB:206F:3DAF8EB:86C9223:59A49CE4")
        |> Plug.Conn.put_resp_header("x-oauth-scopes", "")
        |> Plug.Conn.put_resp_header("x-ratelimit-limit", "5000")
        |> Plug.Conn.put_resp_header("x-ratelimit-remaining", "5000")
        |> Plug.Conn.put_resp_header("x-ratelimit-reset", "1503960268")
        |> Plug.Conn.put_resp_header("x-runtime-rack", "0.015669")
        |> Plug.Conn.put_resp_header("x-xss-protection", "1; mode=block")
    end

    defp new_releases_connection_with_headers(conn, 1) do
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

    defp new_releases_connection_with_headers(conn, 2) do
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
        |> Plug.Conn.put_resp_header("x-github-request-id", "DE90:2070:4B14F0C:9E475BE:59A3C08E")
        |> Plug.Conn.put_resp_header("x-oauth-scopes", "")
        |> Plug.Conn.put_resp_header("x-ratelimit-limit", "5000")
        |> Plug.Conn.put_resp_header("x-ratelimit-remaining", "4992")
        |> Plug.Conn.put_resp_header("x-ratelimit-reset", "1503905273")
        |> Plug.Conn.put_resp_header("x-runtime-rack", "0.055600")
        |> Plug.Conn.put_resp_header("x-xss-protection", "1; mode=block")
    end

    defp no_new_releases_connection_with_headers(conn) do
      conn
        |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
        |> Plug.Conn.put_resp_header("access-control-expose-headers", "ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval")
        |> Plug.Conn.put_resp_header("cache-control", "no-cache")
        |> Plug.Conn.put_resp_header("content-encoding", "gzip")
        |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
        |> Plug.Conn.put_resp_header("content-security-policy", "default-src 'none'")
        |> Plug.Conn.put_resp_header("date", "Mon, 28 Aug 2017 21:06:59 GMT")
        |> Plug.Conn.put_resp_header("server", "GitHub.com")
        |> Plug.Conn.put_resp_header("status", "200 OK")
        |> Plug.Conn.put_resp_header("strict-transport-security", "max-age=31536000; includeSubdomains; preload")
        |> Plug.Conn.put_resp_header("x-accepted-oauth-scopes", "repo")
        |> Plug.Conn.put_resp_header("x-content-type-options", "nosniff")
        |> Plug.Conn.put_resp_header("x-frame-options", "deny")
        |> Plug.Conn.put_resp_header("x-github-media-type", "github.v4; format=json")
        |> Plug.Conn.put_resp_header("x-github-request-id", "C16E:2071:6FF1EE4:E38B049:59A485F3")
        |> Plug.Conn.put_resp_header("x-oauth-scopes", "")
        |> Plug.Conn.put_resp_header("x-ratelimit-limit", "5000")
        |> Plug.Conn.put_resp_header("x-ratelimit-remaining", "4999")
        |> Plug.Conn.put_resp_header("x-ratelimit-reset", "1503958019")
        |> Plug.Conn.put_resp_header("x-runtime-rack", "0.048417")
        |> Plug.Conn.put_resp_header("x-xss-protection", "1; mode=block")
    end

    def rate_limit_json do
      """
      {
        "resources": {
          "core": {
            "limit": 5000,
            "remaining": 4823,
            "reset": 1503961236
          },
          "search": {
            "limit": 30,
            "remaining": 30,
            "reset": 1503960352
          },
          "graphql": {
            "limit": 5000,
            "remaining": 4999,
            "reset": 1503960244
          }
        },
        "rate": {
          "limit": 5000,
          "remaining": 4823,
          "reset": 1503961236
        }
      }
      """
    end

    defp new_releases_json(1) do
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

    defp new_releases_json(2) do
      """
      {
        "data": {
          "rateLimit": {
            "cost": 1,
            "limit": 5000,
            "nodeCount": 5,
            "remaining": 4992,
            "resetAt": "2017-08-28T07:27:53Z"
          },
          "repository": {
            "releases": {
              "edges": [
                {
                  "node": {
                    "id": "MDc6UmVsZWFzZTcyNDQxOTA=",
                    "name": "",
                    "isDraft": false,
                    "isPrerelease": false,
                    "publishedAt": "2017-08-01T15:47:20Z",
                    "tag": {
                      "name": "v1.5.1"
                    }
                  },
                  "cursor": "Y3Vyc29yOnYyOpHOAG6Jng=="
                }
              ],
              "pageInfo": {
                "endCursor": "Y3Vyc29yOnYyOpHOAG6Jng==",
                "hasNextPage": false,
                "hasPreviousPage": true,
                "startCursor": "Y3Vyc29yOnYyOpHOAG6Jng=="
              }
            }
          }
        }
      }
      """
    end

    defp no_new_releases_json do
      """
      {
        "data": {
          "rateLimit": {
            "cost": 1,
            "limit": 5000,
            "nodeCount": 5,
            "remaining": 4999,
            "resetAt": "2017-08-28T22:06:59Z"
          },
          "repository": {
            "releases": {
              "edges": [],
              "pageInfo": {
                "endCursor": null,
                "hasNextPage": false,
                "hasPreviousPage": true,
                "startCursor": null
              }
            }
          }
        }
      }
      """
    end
  end
end
