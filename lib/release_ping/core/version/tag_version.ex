defmodule ReleasePing.Core.Version.TagVersion do
  alias ReleasePing.Core.Version.{PlainVersion, SemanticVersion}

  @behaviour SemanticVersion

  def parse(version, _regex), do: parse(version)
  def parse("v" <> rest_of_version) do
    PlainVersion.parse(rest_of_version)
  end

  def name("v" <> rest_of_version), do: rest_of_version
end
