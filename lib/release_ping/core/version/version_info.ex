defmodule ReleasePing.Core.Version.VersionInfo do
  alias ReleasePing.Conversion

  @type t :: %__MODULE__{
    major: non_neg_integer,
    minor: non_neg_integer,
    patch: non_neg_integer,
    pre_release: String.t,
    build_metadata: String.t,
    published_at: String.t,
  }

  defstruct [:major, :minor, :patch, :pre_release, :build_metadata, :published_at]

  @spec parse(String.t, Regex.t) :: t
  def parse(version_string, version_scheme) do
    named_captures = Regex.named_captures(version_scheme, version_string)
    Map.merge(
      %__MODULE__{
        major: 0,
        minor: 0,
        patch: 0,
        build_metadata: nil,
        pre_release: nil,
      },
      %__MODULE__{
        major: parse_number(named_captures["major"]),
        minor: parse_number(named_captures["minor"]),
        patch: parse_number(named_captures["patch"]),
        pre_release: normalize_pre_release(named_captures["pre_release"]),
        build_metadata: named_captures["build_metadata"],
      },
      &update_unless_blank/3
    )
  end

  @spec published_at(t, String.t) :: t
  def published_at(version_info, iso8601_datestring) do
    %__MODULE__{version_info | published_at: Conversion.from_iso8601_to_naive_datetime(iso8601_datestring)}
  end

  @spec valid?(String.t, Regex.t) :: boolean
  def valid?(version_string, version_scheme) do
    String.match?(version_string, version_scheme)
  end

  @spec pre_release?(String.t, Regex.t) :: boolean
  def pre_release?(version_string, version_scheme) do
    parse(version_string, version_scheme).pre_release != nil
  end

  @spec from_map(map) :: t
  def from_map(version_info) do
    %__MODULE__{
      major: version_info["major"],
      minor: version_info["minor"],
      patch: version_info["patch"],
      pre_release: version_info["pre_release"],
      build_metadata: version_info["build_metadata"],
      published_at: Conversion.from_iso8601_to_naive_datetime(version_info["published_at"]),
    }
  end

  @spec default_version_scheme :: Regex.t
  def default_version_scheme do
    ~r/(?<major>\d+)\.(?<minor>\d+)(?:\.(?<patch>\d+))?(?:-(?<pre_release>.+))?/
  end

  defp update_unless_blank(_k, v1, ""), do: v1
  defp update_unless_blank(_k, _v1, v2), do: v2

  defp parse_number(nil), do: 0
  defp parse_number(""), do: 0
  defp parse_number(string), do: String.to_integer(string)

  defp normalize_pre_release(nil), do: nil
  defp normalize_pre_release(pre_release) do
    pre_release |> String.downcase |> String.replace("_", "-")
  end
end
