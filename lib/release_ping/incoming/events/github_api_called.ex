defmodule ReleasePing.Incoming.Events.GithubApiCalled do
  @type t :: %__MODULE__{
    uuid: String.t,
    github_uuid: String.t,
    http_url: String.t,
    http_method: String.t,
    http_status_code: non_neg_integer,
    content_length: non_neg_integer,
    github_request_id: String.t,
    rate_limit_cost: non_neg_integer,
    rate_limit_total: non_neg_integer,
    rate_limit_remaining: non_neg_integer,
    rate_limit_reset: String.t,
  }

  defstruct [
    :uuid,
    :github_uuid,
    :http_url,
    :http_method,
    :http_status_code,
    :content_length,
    :github_request_id,
    :rate_limit_cost,
    :rate_limit_total,
    :rate_limit_remaining,
    :rate_limit_reset,
  ]
end
