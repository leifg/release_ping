defmodule ReleasePing.Core.Version.SemanticVersion do
  alias ReleasePing.Core.Version.{OtpVersion, PlainVersion}

  @type t :: %__MODULE__{
    major: non_neg_integer,
    minor: non_neg_integer,
    patch: non_neg_integer,
    pre_release: String.t,
  }

  defstruct [:major, :minor, :patch, :pre_release]

  @type update_type :: :major | :minor | :patch

  @callback parse(String.t) :: t
  @callback parse(String.t, Regex.t) :: t
  @callback name(String.t) :: String.t

  @spec parse(String.t, Regex.t) :: t
  def parse(version_string, version_scheme) do
    named_captures = Regex.named_captures(version_scheme, version_string)
    Map.merge(
      %__MODULE__{
        major: 0,
        minor: 0,
        patch: 0,
        pre_release: nil,
      },
      %__MODULE__{
        major: parse_number(named_captures["major"]),
        minor: parse_number(named_captures["minor"]),
        patch: parse_number(named_captures["patch"]),
        pre_release: named_captures["pre_release"],
      },
      &update_unless_blank/3
    )
  end

  @spec from_map(map) :: t
  def from_map(version_info) do
    %__MODULE__{
      major: version_info["major"],
      minor: version_info["minor"],
      patch: version_info["patch"],
      pre_release: version_info["pre_release"],
    }
  end

  @spec default_version_scheme :: String.t
  def default_version_scheme do
    ~r/(?<major>\d+)\.(?<minor>\d+)(?:\.(?<patch>\d+))?(?:-(?<pre_release>.+))?/
  end

  @spec parse(String.t) :: t
  def parse("v" <> rest_of_version) do
    PlainVersion.parse(rest_of_version)
  end

  def parse("OTP-" <> rest_of_version) do
    OtpVersion.parse(rest_of_version)
  end

  def parse("OTP_" <> rest_of_version) do
    OtpVersion.parse(rest_of_version)
  end

  def parse(version) do
    PlainVersion.parse(version)
  end

  @spec name(String.t) :: String.t
  def name("v" <> rest_of_version) do
    PlainVersion.name(rest_of_version)
  end

  def name("OTP-" <> rest_of_version) do
    OtpVersion.name(rest_of_version)
  end

  def name("OTP_" <> rest_of_version) do
    OtpVersion.name(rest_of_version)
  end

  def name(version) do
    PlainVersion.name(version)
  end

  defp update_unless_blank(_k, v1, ""), do: v1
  defp update_unless_blank(_k, _v1, v2), do: v2

  defp parse_number(""), do: 0
  defp parse_number(string), do: String.to_integer(string)
end
