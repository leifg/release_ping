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
      command = %PollGithubReleases{
        repo_owner: "elixir-lang",
        repo_name: "elixir",
      }

      assert_events(aggregate, command, [
        %GithubApiCalled{
          github_uuid: aggregate.uuid,
          http_url: aggregate.base_url,
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
          github_uuid: aggregate.uuid,
          repo_owner: "elixir-lang",
          repo_name: "elixir",
          last_cursor: "Y3Vyc29yOnYyOpHOAAJGkw==",
          payload: hardcoded_response(),
        },
      ])

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

  defp hardcoded_response do
    %{
      "data" => %{
        "rateLimit" => %{
          "cost" => 1,
          "limit" => 5000,
          "nodeCount" => 10,
          "remaining" => 4999,
          "resetAt" => "2017-08-27T10:15:57Z"
        },
        "repository" => %{
          "releases" => %{
            "edges" => [
              %{
                "cursor" => "Y3Vyc29yOnYyOpHNJt0=",
                "node" => %{
                  "id" => "MDc6UmVsZWFzZTk5NDk=",
                  "isDraft" => false,
                  "name" => "v0.10.0",
                  "tag" => %{"name" => "v0.10.0"}
                }
              },
              %{
                "cursor" => "Y3Vyc29yOnYyOpHNUA8=",
                "node" => %{
                  "id" => "MDc6UmVsZWFzZTIwNDk1",
                  "isDraft" => false,
                  "name" => "v0.10.1",
                  "tag" => %{"name" => "v0.10.1"}
                }
              },
              %{
                "cursor" => "Y3Vyc29yOnYyOpHNlGw=",
                "node" => %{
                  "id" => "MDc6UmVsZWFzZTM3OTk2",
                  "isDraft" => false,
                  "name" => "v0.10.2",
                  "tag" => %{"name" => "v0.10.2"}
                }
              },
              %{
                "cursor" => "Y3Vyc29yOnYyOpHN4PA=",
                "node" => %{
                  "id" => "MDc6UmVsZWFzZTU3NTg0",
                  "isDraft" => false, "name" => "v0.10.3",
                  "tag" => %{"name" => "v0.10.3"}
                }
              },
              %{
                "cursor" => "Y3Vyc29yOnYyOpHOAAFDbg==",
                "node" => %{
                  "id" => "MDc6UmVsZWFzZTgyNzk4",
                  "isDraft" => false,
                  "name" => "v0.11.0",
                  "tag" => %{"name" => "v0.11.0"}
                }
              },
              %{
                "cursor" => "Y3Vyc29yOnYyOpHOAAFVfQ==",
                "node" => %{
                  "id" => "MDc6UmVsZWFzZTg3NDIx",
                  "isDraft" => false,
                  "name" => "v0.11.1",
                  "tag" => %{"name" => "v0.11.1"}
                }
              },
              %{
                "cursor" => "Y3Vyc29yOnYyOpHOAAFs6g==",
                "node" => %{
                  "id" => "MDc6UmVsZWFzZTkzNDE4",
                  "isDraft" => false,
                  "name" => "v0.11.2",
                  "tag" => %{"name" => "v0.11.2"}
                }
              },
              %{
                "cursor" => "Y3Vyc29yOnYyOpHOAAHfcA==",
                "node" => %{
                  "id" => "MDc6UmVsZWFzZTEyMjczNg==",
                  "isDraft" => false,
                  "name" => "v0.12.0",
                  "tag" => %{"name" => "v0.12.0"}
                }
              },
              %{
                "cursor" => "Y3Vyc29yOnYyOpHOAAIYvw==",
                "node" => %{
                  "id" => "MDc6UmVsZWFzZTEzNzQwNw==",
                  "isDraft" => false,
                  "name" => "v0.12.1",
                  "tag" => %{"name" => "v0.12.1"}
                }
              },
              %{
                "cursor" => "Y3Vyc29yOnYyOpHOAAJGkw==",
                "node" => %{
                  "id" => "MDc6UmVsZWFzZTE0OTEzOQ==",
                  "isDraft" => false,
                  "name" => "v0.12.2",
                  "tag" => %{"name" => "v0.12.2"}
                }
              }
            ],
            "pageInfo" => %{
              "endCursor" => "Y3Vyc29yOnYyOpHOAAJGkw==",
              "hasNextPage" => true,
              "hasPreviousPage" => false,
              "startCursor" => "Y3Vyc29yOnYyOpHNJt0="}
            }
          }
        }
      }
  end
end
