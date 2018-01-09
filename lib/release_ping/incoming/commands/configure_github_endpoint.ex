defmodule ReleasePing.Incoming.Commands.ConfigureGithubEndpoint do
  @type t :: %__MODULE__{
          uuid: String.t(),
          token: String.t(),
          base_url: String.t()
        }

  defstruct [:uuid, :token, :base_url]
end
