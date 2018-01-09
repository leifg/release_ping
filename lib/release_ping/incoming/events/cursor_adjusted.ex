defmodule ReleasePing.Incoming.Events.CursorAdjusted do
  alias ReleasePing.Incoming.Events.CursorAdjusted

  @type t :: %__MODULE__{
          uuid: String.t(),
          github_uuid: String.t(),
          software_uuid: String.t(),
          repo_owner: String.t(),
          repo_name: String.t(),
          type: ReleasePing.Incoming.Commands.AdjustCursor.cursor_type(),
          cursor: String.t()
        }

  defstruct [
    :uuid,
    :github_uuid,
    :software_uuid,
    :repo_owner,
    :repo_name,
    :type,
    :cursor
  ]

  defimpl Commanded.Serialization.JsonDecoder, for: CursorAdjusted do
    def decode(event) do
      %CursorAdjusted{event | type: safe_atom_map(event.type)}
    end

    def safe_atom_map(nil), do: nil
    def safe_atom_map(string) when is_binary(string), do: String.to_existing_atom(string)
    def safe_atom_map(other), do: other
  end
end
