defmodule ReleasePing.Core.Commands.CorrectSlug do
  @type t :: %__MODULE__{
          uuid: String.t(),
          software_uuid: String.t(),
          slug: String.t(),
          reason: String.t()
        }

  defstruct uuid: nil,
            software_uuid: nil,
            slug: nil,
            reason: nil
end
