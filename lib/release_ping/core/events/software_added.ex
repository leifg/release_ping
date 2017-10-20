defmodule ReleasePing.Core.Events.SoftwareAdded do
  alias ReleasePing.Core.Events.SoftwareAdded

  @type release_retrieval :: :github_

  @type t :: %__MODULE__{
    uuid: String.t,
    name: String.t,
    slug: String.t,
    type: ReleasePing.Enums.software_type,
    version_scheme: Regex.t,
    release_notes_url_template: String.t,
    website: String.t,
    github: String.t,
    licenses: [String.t],
    release_retrieval: ReleasePing.Enums.release_retrieval,
  }

  defstruct [
    uuid: nil,
    name: nil,
    type: nil,
    slug: nil,
    version_scheme: nil,
    release_notes_url_template: nil,
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

  defimpl Poison.Encoder, for: SoftwareAdded do
    def encode(%{version_scheme: %Regex{} = version_scheme} = added, options) do
      Poison.Encoder.Map.encode(%{added | version_scheme: Regex.source(version_scheme)}, options)
    end
  end
end
