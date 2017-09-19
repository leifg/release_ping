defmodule ReleasePing.Core.Version.SemanticVersion do
  alias ReleasePing.Core.Version.{OtpVersion, PlainVersion}

  defstruct [:major, :minor, :patch]

  @type t :: %__MODULE__{
    major: non_neg_integer,
    minor: non_neg_integer,
    patch: non_neg_integer,
  }

  @type update_type :: :major | :minor | :patch

  @callback parse(String.t) :: t
  @callback name(String.t) :: String.t

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
end
