defmodule ReleasePing.Core.Events.SoftwareAdded do
  alias ReleasePing.Core.Events.SoftwareAdded

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    type: String.t,
    version_scheme: String.t,
    website: String.t,
    github: String.t,
    licenses: [String.t],
    release_retrieval: String.t,
  }

  defstruct [
    uuid: nil,
    name: nil,
    version_scheme: nil,
    type: nil,
    website: nil,
    github: nil,
    licenses: [],
    release_retrieval: nil,
  ]

  defimpl Commanded.Serialization.JsonDecoder, for: SoftwareAdded do
    def decode(event) do
      %SoftwareAdded{event |
        version_scheme: deserialize_version_scheme(event.version_scheme),
        type: safe_atom_map(event.type),
        release_retrieval: safe_atom_map(event.release_retrieval),
      }
    end

    defp deserialize_version_scheme(nil), do: nil
    defp deserialize_version_scheme(version_scheme), do: Regex.compile!(version_scheme)

    def safe_atom_map(nil), do: nil
    def safe_atom_map(string) when is_binary(string), do: String.to_existing_atom(string)
    def safe_atom_map(other), do: other
  end
end
