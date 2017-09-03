defmodule ReleasePing.Incoming.Aggregates.GithubEndpointTest do
  alias ReleasePing.Incoming.Aggregates.GithubEndpoint
  alias ReleasePing.Incoming.Commands.ConfigureGithubEndpoint
  alias ReleasePing.Incoming.Commands.PollGithubReleases
  alias ReleasePing.Incoming.Events.GithubEndpointConfigured
  alias ReleasePing.Incoming.Events.NewGithubReleasesFound
  alias ReleasePing.Incoming.Events.GithubApiCalled

  alias ReleasePing.Fixtures.GithubResponses

  use ReleasePing.AggregateCase, aggregate: GithubEndpoint

  describe "configure github endpoint" do
    setup do
      bypass = Bypass.open

      {:ok, %{bypass: bypass}}
    end

    test "succeeds when valid", %{bypass: bypass} do
      Bypass.expect bypass, "GET", "/rate_limit", fn conn ->
        conn
          |> GithubResponses.rate_limit_headers()
          |> Plug.Conn.resp(200, GithubResponses.rate_limit_json())
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
          |> GithubResponses.new_releases_connection_with_headers(page)
          |> Plug.Conn.resp(200, GithubResponses.new_releases_json(page))
      end

      github_uuid = aggregate.uuid

      command = %PollGithubReleases{
        uuid: UUID.uuid4(),
        github_uuid: github_uuid,
        repo_owner: "erlang",
        repo_name: "otp",
      }

      assertion_fun = fn(inner_aggregate, events, _error) ->
        payload_1_size = 1 |> GithubResponses.new_releases_json() |> byte_size()
        payload_2_size = 2 |> GithubResponses.new_releases_json() |> byte_size()

        assert [
          %GithubApiCalled{
            uuid: uuid1,
            github_uuid: ^github_uuid,
            http_method: "post",
            http_status_code: 200,
            content_length: ^payload_1_size,
            github_request_id: "C35A:2071:642FCB9:CAED084:59A3BAFA",
            rate_limit_cost: 1,
            rate_limit_total: 5000,
            rate_limit_remaining: 4993,
            rate_limit_reset: "2017-08-28T07:27:53Z",
          },
          %GithubApiCalled{
            uuid: uuid2,
            github_uuid: ^github_uuid,
            http_method: "post",
            http_status_code: 200,
            content_length: ^payload_2_size,
            github_request_id: "DE90:2070:4B14F0C:9E475BE:59A3C08E",
            rate_limit_cost: 1,
            rate_limit_total: 5000,
            rate_limit_remaining: 4992,
            rate_limit_reset: "2017-08-28T07:27:53Z",
          },
          %NewGithubReleasesFound{
            uuid: uuid3,
            github_uuid: ^github_uuid,
            repo_owner: "erlang",
            repo_name: "otp",
            last_cursor_releases: "Y3Vyc29yOnYyOpHOAGd7TQ==",
            last_cursor_tags: "MTAx",
            payload: [payload1, payload2],
          },
        ] = events

        assert is_map(payload1)
        assert is_map(payload2)

        refute is_nil(uuid1)
        refute is_nil(uuid2)
        refute is_nil(uuid3)

        assert inner_aggregate.rate_limit_total == 5000
        assert inner_aggregate.rate_limit_remaining == 4992
        assert inner_aggregate.rate_limit_reset == ~N[2017-08-28 07:27:53]

        assert inner_aggregate.last_cursors == %{
          {"erlang", "otp"} => %{releases: "Y3Vyc29yOnYyOpHOAGd7TQ==", tags: "MTAx"}
        }
      end

      assert_events(aggregate, command, assertion_fun)
    end

    test "suceeds without new releases", %{aggregate: aggregate, bypass: bypass} do
      Bypass.expect bypass, "POST", "/graphql", fn conn ->
        conn
          |> GithubResponses.no_new_releases_connection_with_headers()
          |> Plug.Conn.resp(200, GithubResponses.no_new_releases_json())
      end

      github_uuid = aggregate.uuid

      command = %PollGithubReleases{
        github_uuid: github_uuid,
        repo_owner: "erlang",
        repo_name: "otp",
      }

      assertion_fun = fn(_aggregate, events, _error) ->
        assert [
          %GithubApiCalled{
            github_uuid: ^github_uuid,
            http_method: "post",
            http_status_code: 200,
            content_length: 611,
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
  end
end
