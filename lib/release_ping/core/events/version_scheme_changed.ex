defmodule ReleasePing.Core.Events.VersionSchemeChanged do
  alias ReleasePing.Core.Events.VersionSchemeChanged

  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    version_scheme: String.t,
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    version_scheme: nil,
  ]

  defimpl Commanded.Serialization.JsonDecoder, for: VersionSchemeChanged do
    def decode(event) do
      %VersionSchemeChanged{event |
        version_scheme: deserialize_version_scheme(event.version_scheme),
      }
    end

    defp deserialize_version_scheme(nil), do: nil
    defp deserialize_version_scheme(version_scheme), do: Regex.compile!(version_scheme)
  end
end
