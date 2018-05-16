defmodule ReleasePing.Core.Commands.MoveGithubRepository do
  @type t :: %__MODULE__{
          uuid: String.t(),
          software_uuid: String.t(),
          github: String.t()
        }

  defstruct uuid: nil,
            software_uuid: nil,
            github: nil
end
