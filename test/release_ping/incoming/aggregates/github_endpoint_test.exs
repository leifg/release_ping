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
        uuid: UUID.uuid4(),
        github_uuid: github_uuid,
        repo_owner: "elixir-lang",
        repo_name: "elixir",
      }

      assertion_fun = fn(inner_aggregate, events, _error) ->
        payload_1_size = 1 |> new_releases_json() |> byte_size()
        payload_2_size = 2 |> new_releases_json() |> byte_size()

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
          %NewGithubReleasesFound{
            uuid: uuid2,
            github_uuid: ^github_uuid,
            repo_owner: "elixir-lang",
            repo_name: "elixir",
            last_cursor: "Y3Vyc29yOnYyOpHOAG0tAw==",
            payload: payload_1,
          },
          %GithubApiCalled{
            uuid: uuid3,
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
            uuid: uuid4,
            github_uuid: ^github_uuid,
            repo_owner: "elixir-lang",
            repo_name: "elixir",
            last_cursor: "Y3Vyc29yOnYyOpHOAG6Jng==",
            payload: payload_2,
          },
        ] = events

        assert is_list(payload_1)
        assert is_list(payload_2)

        refute is_nil(uuid1)
        refute is_nil(uuid2)
        refute is_nil(uuid3)
        refute is_nil(uuid4)

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
                    "description": "This version includes changes that make Elixir fully compatible with Erlang/OTP 20.\\r\\n\\r\\n### 1. Enhancements\\r\\n\\r\\n#### Logger\\r\\n\\r\\n  * [Logger] Handle changes to crash reports in OTP 20\\r\\n\\r\\n### 2. Bug fixes\\r\\n\\r\\n#### Elixir\\r\\n\\r\\n  * [DateTime] Fix `DateTime.from_iso8601/2` when offset has no colon\\r\\n  * [Registry] Do not leak EXIT messages on `Registry.dispatch/3`",
                    "tag": {
                      "id": "MDM6UmVmMTIzNDcxNDp2MS40LjU=",
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
                    "description": "",
                    "tag": {
                      "id": "MDM6UmVmMTIzNDcxNDp2MS41LjAtcmMuMA==",
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
                    "description": "",
                    "tag": {
                      "id": "MDM6UmVmMTIzNDcxNDp2MS41LjAtcmMuMg==",
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
                    "description": "",
                    "tag": {
                      "id": "MDM6UmVmMTIzNDcxNDp2MS41LjAtcmMuMg==",
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
                    "description": "Official announcement: https://elixir-lang.org/blog/2017/07/25/elixir-v1-5-0-released/\\r\\n\\r\\n### 1. Enhancements\\r\\n\\r\\n#### Elixir\\r\\n\\r\\n  * [Access] Optimize `Access.get/2`\\r\\n  * [Base] Optimize Base encode/decode\\r\\n  * [Calendar] Implement Inspect for DateTime with Calendar.ISO\\r\\n  * [Calendar] Add \\"ISO days\\" format for conversions between Calendars and `Date.convert/2`, `Time.convert/2`, `NaiveDateTime.convert/2` and `DateTime.convert/2` (as well as bang variants)\\r\\n  * [Calendar] Add `:calendar` field to `Time` struct\\r\\n  * [Calendar] Add `Time.diff/3`, `Date.add/2`, `Date.diff/2`, `DateTime.diff/3`\\r\\n  * [Calendar] Add `Date.range/2`\\r\\n  * [Calendar] Add `Date.new/4`, `DateTime.utc_now/1`, `NaiveDateTime.new/8` and `Time.new/5` that allow specifing calendar\\r\\n  * [Enum] Add `Enum.chunk_by/4` and `Stream.chunk_by/4`\\r\\n  * [Enum] Add `Enum.chunk_every/2` and `Enum.chunk_every/4` with a more explicit API than `Enum.chunk/2` and `Enum.chunk/4`\\r\\n  * [Exception] Add `Exception.blame/3` that adds metadata to exceptions\\r\\n  * [File] Add `File.read_link/1` and `File.read_link!/1`\\r\\n  * [File] Introduce `:trim_bom` option for `File.stream!/2`\\r\\n  * [Inspect] Add `:printable_limit` to control the limit of printable structures\\r\\n  * [Integer] Add `Integer.gcd/2`\\r\\n  * [Kernel] Add `left not in right` to check that the left side is not in the enumerable on the right\\r\\n  * [Kernel] Use the new `debug_info` chunk in OTP 20. This provides a mechanism for tools to retrieve the Elixir AST from beam files\\r\\n  * [Kernel] `defoverridable/1` accepts a module name as argument and marks all callbacks as overridable\\r\\n  * [Kernel] Allow non-quoted Unicode atoms and variables according to Unicode Annex #31 (see Unicode Syntax document)\\r\\n  * [Kernel] Warn when a `:__struct__` key is used when building/updating structs\\r\\n  * [Kernel] Cache the AST on definitions. This speeds up the compilation time from 10% to 15% measured across different projects\\r\\n  * [Kernel] Improve compiler error message on invalid patterns and guards\\r\\n  * [Keyword] Add `replace/3` and `replace!/3` for replacing an existing key\\r\\n  * [List] `List.starts_with?/2`\\r\\n  * [Macro] Introduce `Macro.generate_arguments/2`\\r\\n  * [Map] Optimize `Map.merge/3` by choosing merging direction\\r\\n  * [Map] Add `replace/3` and `replace!/3` for replacing an existing key\\r\\n  * [Map] Raise `BadMapError` in `Map.equal?/2` when either of the two arguments is not a map\\r\\n  * [MapSet] Reduce `MapSet` size when serialized to approximately half\\r\\n  * [Process] Add `Process.cancel_timer/2`\\r\\n  * [Protocol] Show available implementations on `Protocol.UndefinedError` if the protocol has been consolidated\\r\\n  * [Registry] Support ETS guard conditions in `Registry.match/3`\\r\\n  * [Registry] Support `parallel: true` in `Registry.dispatch/3`\\r\\n  * [Registry] Introduce `Registry.unregister_match/4`\\r\\n  * [Stream] Add `Stream.chunk_every/2` and `Stream.chunk_every/4` with a more explicit API than `Stream.chunk/2` and `Stream.chunk/4`\\r\\n  * [String] Optimise binary pattern matching in `String.split/1` and `String.trim_*/1`\\r\\n  * [Supervisor] Add `Supervisor.init/2` and `Supervisor.child_spec/2`\\r\\n  * [Supervisor] Allow `module` and `{module, arg}` to be given to `Supervisor.start_link/2` and invoke `module.child_spec(arg)` on each argument\\r\\n  * [Task] Support `:on_timeout` in `Task.async_stream` to control how tasks are terminated\\r\\n  * [Task] Add `ordered: false` support to `Task.async_stream`\\r\\n\\r\\n#### ExUnit\\r\\n\\r\\n  * [ExUnit] Show code snippet from test source file in case of test errors\\r\\n  * [ExUnit] Use `Exception.blame/3` when formatting test errors\\r\\n  * [ExUnit] Make `assert_raise/2` fail if the underlying exception has a broken `message/1` implementation\\r\\n  * [ExUnit] Add `start_supervised/2` and `stop_supervised/1` to ExUnit. Processes started by this function are automatically shut down when the test exits\\r\\n\\r\\n#### IEx\\r\\n\\r\\n  * [IEx.Autocomplete] Support autocompletion of variable names\\r\\n  * [IEx.Autocomplete] Support autocompletion of functions imported using `import Mod, only: [...]`\\r\\n  * [IEx.Evaluator] Use `Exception.blame/3` when showing errors in the terminal\\r\\n  * [IEx.Helpers] Add `exports/1` IEx helper to list all exports in a module\\r\\n  * [IEx.Helpers] Add `break!/2`, `break!/4`, `breaks/0`, `continue/0`, `open/0`, `remove_breaks/0`, `remove_breaks/1`, `reset_break/1`, `reset_break/3` and `whereami/1` for code debugging\\r\\n  * [IEx.Helpers] No longer emit warnings for IEx commands without parentheses\\r\\n  * [IEx.Helpers] Add `runtime_info/0` for printing runtime system information\\r\\n  * [IEx.Helpers] Add `open/1` to open the source of a given module/function in your editor\\r\\n  * [IEx.Info] Implement `IEx.Info` protocol for calendar types\\r\\n\\r\\n#### Logger\\r\\n\\r\\n  * [Logger] Add `metadata: :all` configuration to log all metadata\\r\\n\\r\\n#### Mix\\r\\n\\r\\n  * [mix compile.elixir] Add `--all-warnings` option to Elixir compiler that shows all warnings from the previous compilation (instead of just of the files being compiled)\\r\\n  * [mix escript.build] Strip debug information from escripts by default and add option `:strip_beam` which defaults to true\\r\\n  * [mix loadpaths] Ensure `--no-deps-check` do not trigger SCM callbacks (such as `git`)\\r\\n  * [mix local.hex] Add `--if-missing` flag to `local.hex` mix task\\r\\n  * [mix profile.cprof] Add `Mix.Tasks.Profile.Cprof` for count-based profiling\\r\\n  * [mix new] New styling for generated applications\\r\\n\\r\\n### 2. Bug fixes\\r\\n\\r\\n#### Elixir\\r\\n\\r\\n  * [Calendar] Ensure `Calendar.ISO` raises a readable error when reaching up the year 10000 restriction\\r\\n  * [Calendar] Return `{:error, :invalid_time}` for wrong precision instead of crashing when parsing ISO dates\\r\\n  * [Enumerable] Raise `Protocol.UndefinedError` on bad functions in Enumerable implementation\\r\\n  * [File] Ensure recursive file operations raise on paths with null bytes (*security issue reported by Griffin Byatt*)\\r\\n  * [File] Support `:ram`/`:raw` files in `File.copy/2`\\r\\n  * [Inspect] Do not use colors when inspecting error messages\\r\\n  * [Kernel] Support guards on anonymous functions of zero arity\\r\\n  * [Kernel] Fix compilation of maps used as maps keys inside matches\\r\\n  * [Kernel] Ensure `do` clause in `with` is tail call optimizable\\r\\n  * [Module] `on_definition/6` callback receives body wrapped in a keyword list, such as `[do: body]`. This solves a bug where it was impossible to distinguish between a bodyless clause and a function that returns `nil`.\\r\\n  * [Path] Ensure recursive path operations raise on paths with null bytes (*security issue reported by Griffin Byatt*)\\r\\n  * [Protocol] Do not lose source compile info on protocol consolidation\\r\\n  * [Record] Properly escape quoted expressions passed to `defrecord`\\r\\n  * [Regex] Fix `inspect/2` for regexes with `/` terminator in them\\r\\n  * [Registry] Ensure `Registry.match/4` works with `:_` as key\\r\\n  * [Stream] Fix stream cycle over empty enumerable\\r\\n  * [String] Consider Unicode non-characters valid according to the specification in `String.valid?/1`\\r\\n  * [StringIO] Fix encoding and performance issues in `StringIO.get_until`\\r\\n  * [System] Raise on paths with null bytes in `System.cmd/2` and in `System.find_executable/1` (*security issue reported by Griffin Byatt*)\\r\\n  * [System] Raise on ill-formed environment variables (*security issue reported by Griffin Byatt*)\\r\\n\\r\\n#### ExUnit\\r\\n\\r\\n  * [ExUnit] Properly account failed tests when `setup_all` fails\\r\\n\\r\\n#### IEx\\r\\n\\r\\n  * [IEx] Skip autocompletion of module names that are invalid without being quoted\\r\\n  * [IEx] Skip autocompletion of functions with default arguments with `@doc false`\\r\\n  * [IEx] Do not start oldshell alongside IEx\\r\\n\\r\\n#### Mix\\r\\n\\r\\n  * [mix compile.elixir] Store multiple sources in case of module conflicts. This solves an issue where `_build` would get corrupted when compiling Elixir projects with module conflicts\\r\\n  * [mix compile.erlang] Do not silently discard Erlang compile errors\\r\\n  * [mix compile.erlang] Properly track `-compile` module attribute when specified as a list\\r\\n  * [mix compile.protocols] Ensure protocol implementations do not \\"disappear\\" when switching between applications in umbrella projects by having separate consolidation paths per project\\r\\n  * [mix compile.protocols] Do not raise when consolidating a protocol that was converted into a module\\r\\n\\r\\n### 3. Soft deprecations (no warnings emitted)\\r\\n\\r\\n#### Elixir\\r\\n\\r\\n  * [Kernel] `not left in right` is soft-deprecated in favor of `left not in right`\\r\\n\\r\\n### 4. Deprecations\\r\\n\\r\\n#### Elixir\\r\\n\\r\\n  * `Atom.to_char_list/1`, `Float.to_char_list/1`, `Integer.to_char_list/1`, `Integer.to_char_list/2`, `Kernel.to_char_list/1`, `List.Chars.to_char_list/1`, `String.to_char_list/1` have been deprecated in favor of their `to_charlist` version. This aligns with the naming conventions in both Erlang and Elixir\\r\\n  * [Enum] Deprecate `Enum.filter_map/3` in favor of `Enum.filter/2` + `Enum.map/2` or for-comprehensions\\r\\n  * [GenEvent] Deprecate `GenEvent` and provide alternatives in its docs\\r\\n  * [Kernel] Using `()` to mean `nil` is deprecated\\r\\n  * [Kernel] `:as_char_lists value` in `Inspect.Opts.t/0` type, in favor of `:as_charlists`\\r\\n  * [Kernel] `:char_lists` key in `Inspect.Opts.t/0` type, in favor of `:charlists`\\r\\n  * [Module] Using Erlang parse transforms via `@compile {:parse_transform, _}` is deprecated\\r\\n  * [Stream] Deprecate `Stream.filter_map/3` in favor of `Stream.filter/2` + `Stream.map/2`\\r\\n  * [String] `String.ljust/3` and `String.rjust/3` are deprecated in favor of `String.pad_leading/3` and `String.pad_trailing/3` with a binary padding\\r\\n  * [String] `String.strip/1` and `String.strip/2` are deprecated in favor of `String.trim/1` and `String.trim/2`\\r\\n  * [String] `String.lstrip/1` and `String.rstrip/1` are deprecated in favor of `String.trim_leading/1` and `String.trim_trailing/1`\\r\\n  * [String] `String.lstrip/2` and `String.rstrip/2` are deprecated in favor of `String.trim_leading/2` and `String.trim_trailing/2` with a binary as second argument\\r\\n  * [Typespec] `char_list/0` type is deprecated in favor of `charlist/0`\\r\\n\\r\\n#### EEx\\r\\n\\r\\n  * [EEx] Deprecate `<%= ` in \\"middle\\" and \\"end\\" expressions, e.g.: `<%= else %>` and `<%= end %>`\\r\\n",
                    "tag": {
                      "id": "MDM6UmVmMTIzNDcxNDp2MS41LjA=",
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
                    "description": "### 1. Enhancements\\r\\n\\r\\n#### EEx\\r\\n\\r\\n  * [EEx.Engine] Add `handle_begin` and `handle_end` to EEx\\r\\n\\r\\n#### Elixir\\r\\n\\r\\n  * [Kernel] Do not use references on function/macro definitions - this provides large improvements in compilation times in some rare corner cases\\r\\n  * [Supervisor] Support mixing old and new typespecs in `Supervisor.init/2` and `Supevisor.start_link/2`\\r\\n\\r\\n#### Mix\\r\\n\\r\\n  * [mix profile.*] Allow profile tasks to run without a project\\r\\n\\r\\n### 2. Bug fixes\\r\\n\\r\\n#### EEx\\r\\n\\r\\n  * [EEx.Engine] Do not re-use the value of the `init/1` callback throughout the compilation stack\\r\\n\\r\\n#### Elixir\\r\\n\\r\\n  * [Kernel] Ensure dialyzer does not emit warnings in some uses of `with`\\r\\n  * [Kernel] Fix dialyzer warnings when `defmacrop` is used in modules\\r\\n  * [Kernel] Ensure Elixir modules can be dialyzed without starting the Elixir application\\r\\n  * [Kernel] Do not serialize references in quoted expressions\\r\\n  * [Kernel] Make sure structs expansion use the latest definition available when struct modules are recompiled\\r\\n  * [Task] Support `:infinity` timeout on Task streams\\r\\n  * [Typespec] Ensure typespecs allow `tuple` to be used as variable names",
                    "tag": {
                      "id": "MDM6UmVmMTIzNDcxNDp2MS41LjE=",
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
