defmodule ReleasePing.Core.Events.SoftwareTypeCorrected do
  alias ReleasePing.Core.Events.SoftwareTypeCorrected

  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    type: String.t,
    reason: String.t,
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    type: nil,
    reason: nil,
  ]

  defimpl Commanded.Serialization.JsonDecoder, for: SoftwareTypeCorrected do
    def decode(event) do
      %SoftwareTypeCorrected{event |
        type: safe_atom_map(event.type),
      }
    end

    def safe_atom_map(nil), do: nil
    def safe_atom_map(string) when is_binary(string), do: String.to_existing_atom(string)
    def safe_atom_map(other), do: other
  end
end
