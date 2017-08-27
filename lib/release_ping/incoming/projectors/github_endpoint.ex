defmodule ReleasePing.Incoming.Projectors.GithubEndpoint do
  use Commanded.Projections.Ecto, name: "Incoming.Projectors.GithubEndpoint"

  alias ReleasePing.Incoming.Events.{GithubApiCalled, GithubEndpointConfigured}
  alias ReleasePing.Incoming.GithubEndpoint

  project %GithubEndpointConfigured{} = configured, %{stream_version: stream_version} do
    Ecto.Multi.insert(multi, :github_endpoints, %GithubEndpoint{
      uuid: configured.uuid,
      stream_version: stream_version,
      rate_limit_total: 5000,
      rate_limit_remaining: 5000,
      rate_limit_reset: DateTime.utc_now(),
    })
  end

  project %GithubApiCalled{github_uuid: uuid} = api_called, %{stream_version: stream_version} do
    changes = [
      rate_limit_total: api_called.rate_limit_total,
      rate_limit_remaining: api_called.rate_limit_remaining,
      rate_limit_reset: NaiveDateTime.from_iso8601!(api_called.rate_limit_reset),
      stream_version: stream_version,
    ]

    Ecto.Multi.update_all(multi, :github_endpoints, from(gh in GithubEndpoint, where: gh.uuid == ^uuid), [
      set: changes
    ], returning: true)
  end
end
