defmodule ReleasePing.Core.Version.SemanticVersion do
  alias ReleasePing.Core.Version.{PlainVersion, TagVersion}

  defstruct [:major, :minor, :patch]

  @type t :: %__MODULE__{
    major: non_neg_integer,
    minor: non_neg_integer,
    patch: non_neg_integer,
  }

  @type update_type :: :major | :minor | :patch

  @callback parse(String.t) :: t

  @spec parser(String.t) :: module
  defp parser("v" <> _rest_of_version) do
    TagVersion
  end
  defp parser(version_string) do
    PlainVersion
  end


  @spec parse(String.t) :: t
  def parse(version_string) do
    parser(version_string).parse(version_string)
  end
end
