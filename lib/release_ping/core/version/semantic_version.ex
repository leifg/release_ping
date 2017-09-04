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
end
