defmodule ReleasePing.Core.Version.Aggregates.TagVersionTest do
  use ExUnit.Case

  alias ReleasePing.Core.Version.TagVersion
  alias ReleasePing.Core.Version.SemanticVersion

  describe "parse/1" do
    test "parses tag version string correctly" do
      assert TagVersion.parse("v1.5.0") == %SemanticVersion{major: 1, minor: 5, patch: 0}
    end
  end
end
