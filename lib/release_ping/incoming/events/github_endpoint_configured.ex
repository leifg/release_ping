defmodule ReleasePing.Incoming.Events.GithubEndpointConfigured do
  @derive [Poison.Encoder]

  @type t :: %__MODULE__{
    uuid: String.t,
    token: String.t,
    base_url: String.t,
  }

  defstruct [:uuid, :token, :base_url]
end
