defmodule ReleasePing.Core.Events.ReleasePublished do
  alias ReleasePing.Core.Version.VersionInfo
  alias ReleasePing.Core.Events.ReleasePublished

  @type t :: %__MODULE__{
    uuid: String.t,
    software_uuid: String.t,
    version_string: String.t,
    version_info: VersionInfo.t,
    release_notes_url: String.t,
    display_version: String.t,
    published_at: String.t, # ISO 8601 Datetime
    seen_at: String.t, # ISO 8601 Datetime
    github_cursor: String.t,
    pre_release: boolean,
  }

  defstruct [
    uuid: nil,
    software_uuid: nil,
    version_string: nil,
    version_info: nil,
    release_notes_url: nil,
    display_version: nil,
    published_at: nil,
    seen_at: nil,
    github_cursor: nil,
    pre_release: false,
  ]

  defimpl Commanded.Serialization.JsonDecoder, for: ReleasePublished do
    def decode(event) do
      version_info = parse_version(event)
      %ReleasePublished{event |
        version_info: version_info,
        display_version: default_display_version(event.display_version, version_info),
      }
    end

    defp parse_version(%ReleasePublished{version_string: nil}), do: nil
    defp parse_version(%ReleasePublished{version_string: version_string, version_info: nil, published_at: published_at}) do
      version_string
        |> VersionInfo.parse(VersionInfo.default_version_scheme())
        |> VersionInfo.published_at(published_at)
    end
    defp parse_version(%ReleasePublished{version_info: %VersionInfo{} = version_info}), do: version_info
    defp parse_version(%ReleasePublished{version_info: %{} = version_info}) do
      VersionInfo.from_map(version_info)
    end

    defp default_display_version(nil, version_info) do
      parse_display_version(version_info)
    end
    defp default_display_version(display_version, _version_info), do: display_version

    defp parse_display_version(version_info) do
      "#{version_info.major}.#{version_info.minor}.#{version_info.patch}#{pre_release(version_info)}"
    end
  
    defp pre_release(%{pre_release: nil}), do: nil
    defp pre_release(%{pre_release: pre_release}), do: "-#{pre_release}"
  end
end
