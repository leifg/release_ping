defmodule ReleasePing.Incoming.Projectors.GithubEndpointTest do
  alias ReleasePing.Incoming.Projectors.GithubEndpoint
  alias ReleasePing.Incoming.Events.{GithubApiCalled, GithubEndpointConfigured}
  alias ReleasePing.Repo

  use ReleasePing.DataCase
  use Timex

  describe "GithubEndpoint Read Model" do
    test "correctly creates an entry in the read model" do
      uuid = UUID.uuid4()

      event = %GithubEndpointConfigured{
        uuid: uuid,
        base_url: "https://api.github.com/",
        token: "45ec1b65e3ae4ebca6e613ca6266287540679174",
        rate_limit_total: 5000,
        rate_limit_remaining: 4999,
        rate_limit_reset: DateTime.utc_now() |> Timex.shift(seconds: -1) |> DateTime.to_iso8601()
      }

      GithubEndpoint.handle(event, %{stream_version: 1, event_number: 1})

      github_endpoint = Repo.get(ReleasePing.Incoming.GithubEndpoint, uuid)

      assert github_endpoint.rate_limit_total == 5000
      assert github_endpoint.rate_limit_remaining == 4999
      assert DateTime.compare(github_endpoint.rate_limit_reset, DateTime.utc_now()) == :lt

      event = %GithubApiCalled{
        github_uuid: uuid,
        http_method: "post",
        http_status_code: 200,
        content_length: 9125,
        github_request_id: "F8C0:5192:2E5BCD7:7316E87:59A28E64",
        rate_limit_cost: 1,
        rate_limit_total: 8000,
        rate_limit_remaining: 7999,
        rate_limit_reset: DateTime.utc_now() |> Timex.shift(minutes: 30) |> DateTime.to_iso8601()
      }

      GithubEndpoint.handle(event, %{stream_version: 1, event_number: 2})

      github_endpoint = Repo.get(ReleasePing.Incoming.GithubEndpoint, uuid)

      assert github_endpoint.rate_limit_total == 8000
      assert github_endpoint.rate_limit_remaining == 7999
      assert DateTime.compare(github_endpoint.rate_limit_reset, DateTime.utc_now()) == :gt
    end
  end
end
