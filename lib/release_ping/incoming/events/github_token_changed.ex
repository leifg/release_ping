defmodule ReleasePing.Incoming.Events.GithubTokenChanged do
  @type t :: %__MODULE__{
          uuid: String.t(),
          github_uuid: String.t(),
          token: String.t()
        }

  defstruct [:uuid, :github_uuid, :token]
end
