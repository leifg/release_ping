defmodule ReleasePing.Incoming.Aggregates.GithubEndpointTest do
  alias ReleasePing.Incoming.Aggregates.GithubEndpoint

  alias ReleasePing.Incoming.Commands.{
    AdjustCursor,
    ConfigureGithubEndpoint,
    ChangeGithubToken,
    PollGithubReleases
  }

  alias ReleasePing.Incoming.Events.{
    CursorAdjusted,
    GithubApiCalled,
    GithubEndpointConfigured,
    GithubTokenChanged,
    NewGithubReleasesFound
  }

  alias ReleasePing.Fixtures.GithubResponses

  use ReleasePing.AggregateCase, aggregate: GithubEndpoint

  describe "configure github endpoint" do
    setup do
      bypass = Bypass.open()

      {:ok, %{bypass: bypass}}
    end

    test "succeeds when valid", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/rate_limit", fn conn ->
        conn
        |> GithubResponses.rate_limit_headers()
        |> Plug.Conn.resp(200, GithubResponses.rate_limit_json())
      end)

      uuid = UUID.uuid4()
      gh_token = "45ec1b65e3ae4ebca6e613ca6266287540679174"
      base_url = "http://localhost:#{bypass.port}"

      command = %ConfigureGithubEndpoint{
        uuid: uuid,
        token: gh_token,
        base_url: base_url
      }

      assert_events(command, [
        %GithubEndpointConfigured{
          uuid: uuid,
          token: gh_token,
          base_url: base_url,
          rate_limit_total: 5000,
          rate_limit_remaining: 4999,
          rate_limit_reset: "2017-08-28T22:44:04Z"
        }
      ])
    end
  end

  describe "poll release" do
    @cursor_regex ~r/after:\s*(?<cursor>["a-zA-Z0-9=\\]+)/

    setup do
      uuid = UUID.uuid4()
      bypass = Bypass.open()

      event = %GithubEndpointConfigured{
        uuid: uuid,
        token: "45ec1b65e3ae4ebca6e613ca6266287540679174",
        base_url: "http://localhost:#{bypass.port}",
        rate_limit_total: 5000,
        rate_limit_remaining: 5000,
        rate_limit_reset: "2017-08-28T22:44:04Z"
      }

      aggregate = evolve(event)

      {:ok, %{aggregate: aggregate, bypass: bypass}}
    end

    @tag :integration
    test "succeeds with new releases", %{aggregate: aggregate, bypass: bypass} do
      Bypass.expect(bypass, "POST", "/graphql", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        page =
          case Regex.named_captures(@cursor_regex, body) do
            %{"cursor" => "null"} -> 1
            _ -> 2
          end

        conn
        |> GithubResponses.new_releases_connection_with_headers(page)
        |> Plug.Conn.resp(200, GithubResponses.new_releases_json(page))
      end)

      github_uuid = aggregate.uuid
      software_uuid = "e12fabf2-827a-4a09-a817-c27dafc89717"

      command = %PollGithubReleases{
        uuid: UUID.uuid4(),
        github_uuid: github_uuid,
        software_uuid: software_uuid,
        repo_owner: "erlang",
        repo_name: "otp"
      }

      assertion_fun = fn inner_aggregate, events, _error ->
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
                   rate_limit_reset: "2017-08-28T07:27:53Z"
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
                   rate_limit_reset: "2017-08-28T07:27:53Z"
                 },
                 %NewGithubReleasesFound{
                   uuid: uuid3,
                   github_uuid: ^github_uuid,
                   software_uuid: ^software_uuid,
                   repo_owner: "erlang",
                   repo_name: "otp",
                   seen_at: seen_at,
                   last_cursor_releases: "Y3Vyc29yOnYyOpHOAGd7TQ==",
                   last_cursor_tags: "MTAx",
                   payloads: [payload1, payload2]
                 }
               ] = events

        time_difference =
          NaiveDateTime.diff(
            NaiveDateTime.utc_now(),
            NaiveDateTime.from_iso8601!(seen_at),
            :milli_seconds
          )

        assert time_difference < 1000

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
      Bypass.expect(bypass, "POST", "/graphql", fn conn ->
        conn
        |> GithubResponses.no_new_releases_connection_with_headers()
        |> Plug.Conn.resp(200, GithubResponses.no_new_releases_json())
      end)

      github_uuid = aggregate.uuid
      software_uuid = "e12fabf2-827a-4a09-a817-c27dafc89717"

      command = %PollGithubReleases{
        github_uuid: github_uuid,
        software_uuid: software_uuid,
        repo_owner: "erlang",
        repo_name: "otp"
      }

      assertion_fun = fn _aggregate, events, _error ->
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
                   rate_limit_reset: "2017-08-28T22:06:59Z"
                 }
               ] = events
      end

      assert_events(aggregate, command, assertion_fun)
    end

    test "rejects poll release commands without software uuid", %{aggregate: aggregate} do
      github_uuid = aggregate.uuid

      command = %PollGithubReleases{
        github_uuid: github_uuid,
        software_uuid: nil,
        repo_owner: "erlang",
        repo_name: "otp"
      }

      assertion_fun = fn _aggregate, _events, error ->
        assert error == {:error, :software_uuid_missing}
      end

      assert_events(aggregate, command, assertion_fun)
    end
  end

  describe "change github token" do
    setup [:configure_github_endpoint]

    test "github token can be successfully changed", %{aggregate: aggregate} do
      github_uuid = aggregate.uuid

      new_token = "883ae62c54b4cfb8421aad1bf7c0e1013aa887d4"

      command = %ChangeGithubToken{
        uuid: UUID.uuid4(),
        github_uuid: github_uuid,
        token: new_token
      }

      assertion_fun = fn inner_aggregate, event, _error ->
        assert inner_aggregate.token == new_token

        assert %GithubTokenChanged{
                 uuid: uuid,
                 github_uuid: ^github_uuid,
                 token: ^new_token
               } = event

        assert uuid != nil
      end

      assert_events(aggregate, command, assertion_fun)
    end
  end

  describe "adjust cursor" do
    setup [:configure_github_endpoint, :add_new_releases]

    test "cursor can be adjusted", %{aggregate: aggregate} do
      github_uuid = aggregate.uuid
      new_cursor = "MTAw"

      command = %AdjustCursor{
        uuid: UUID.uuid4(),
        github_uuid: github_uuid,
        software_uuid: "e12fabf2-827a-4a09-a817-c27dafc89717",
        repo_owner: "erlang",
        repo_name: "otp",
        type: :tags,
        cursor: new_cursor
      }

      assertion_fun = fn inner_aggregate, event, _error ->
        assert %CursorAdjusted{
                 uuid: uuid,
                 github_uuid: ^github_uuid,
                 software_uuid: "e12fabf2-827a-4a09-a817-c27dafc89717",
                 repo_owner: "erlang",
                 repo_name: "otp",
                 cursor: ^new_cursor,
                 type: :tags
               } = event

        assert uuid != nil
        assert inner_aggregate.last_cursors != aggregate.last_cursors
        assert inner_aggregate.last_cursors[{"erlang", "otp"}][:tags] == new_cursor
      end

      assert_events(aggregate, command, assertion_fun)
    end
  end

  defp configure_github_endpoint(_context) do
    event = %GithubEndpointConfigured{
      uuid: UUID.uuid4(),
      token: "45ec1b65e3ae4ebca6e613ca6266287540679174",
      base_url: "http://localhost:1234",
      rate_limit_total: 5000,
      rate_limit_remaining: 5000,
      rate_limit_reset: "2017-08-28T22:44:04Z"
    }

    aggregate = evolve(event)

    {:ok, %{aggregate: aggregate}}
  end

  defp add_new_releases(%{aggregate: aggregate}) do
    event = %NewGithubReleasesFound{
      uuid: UUID.uuid4(),
      github_uuid: aggregate.uuid,
      software_uuid: "e12fabf2-827a-4a09-a817-c27dafc89717",
      repo_owner: "erlang",
      repo_name: "otp",
      seen_at: "2017-09-04T06:45:58.689811Z",
      last_cursor_releases: "Y3Vyc29yOnYyOpHOAGd7TQ==",
      last_cursor_tags: "MTAx",
      payloads: []
    }

    {:ok, %{aggregate: evolve(event)}}
  end
end
