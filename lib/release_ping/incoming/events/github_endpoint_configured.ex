defmodule ReleasePing.Incoming.Events.GithubEndpointConfigured do
  @type t :: %__MODULE__{
          uuid: String.t(),
          token: String.t(),
          base_url: String.t(),
          rate_limit_total: non_neg_integer,
          rate_limit_remaining: non_neg_integer,
          rate_limit_reset: String.t()
        }

  defstruct [
    :uuid,
    :token,
    :base_url,
    :rate_limit_total,
    :rate_limit_remaining,
    :rate_limit_reset
  ]
end
