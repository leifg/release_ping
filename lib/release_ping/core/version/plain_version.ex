defmodule ReleasePing.Core.Version.PlainVersion do
  alias ReleasePing.Core.Version.SemanticVersion

  @behaviour SemanticVersion

  def parse(version, _regex), do: parse(version)
  def parse(plain_version) do
    {:ok, version} = Version.parse(plain_version)
    %SemanticVersion{
      major: version.major,
      minor: version.minor,
      patch: version.patch,
    }
  end

  def name(plain_version), do: plain_version
end
