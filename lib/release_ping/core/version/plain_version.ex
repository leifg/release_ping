defmodule ReleasePing.Core.Version.PlainVersion do
  alias ReleasePing.Core.Version.SemanticVersion

  @behaviour SemanticVersion

  def parse(plain_version) do
    {:ok, version} = Version.parse(plain_version)
    %SemanticVersion{
      major: version.major,
      minor: version.minor,
      patch: version.patch,
    }
  end
end
