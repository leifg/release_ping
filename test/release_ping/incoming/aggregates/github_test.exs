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

      command = %ConfigureGithubEndpoint{
        uuid: uuid,
        token: "45ec1b65e3ae4ebca6e613ca6266287540679174",
        base_url: "https://api.github.com/graphql",
      }

      {aggregate, _events, _error} = execute(command)
      {:ok, %{aggregate: aggregate}}
    end

    @tag :integration
    test "succeeds with valid data", %{aggregate: aggregate} do
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

      # assert_events build(:pull_github_releases, uuid: uuid), [
      #   %GithubReleasesPolled{
      #     uuid: uuid,
      #     name: "elixir",
      #     website: "https://elixir-lang.org",
      #     github: "elixir-lang/elixir",
      #     licenses: ["MIT"],
      #     release_retrieval: :github_release_poller,
      #   }
      # ]
    end
  end
end
