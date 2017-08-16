defmodule ReleasePing.Core.Version.Aggregates.SemanticVersionTest do
  use ExUnit.Case

  alias ReleasePing.Core.Version.SemanticVersion

  describe "parse" do
    test "returns correct version for plain version" do
      assert SemanticVersion.parse("1.5.0") == %SemanticVersion{major: 1, minor: 5, patch: 0}
    end

    test "returns correct version for tag version" do
      assert SemanticVersion.parse("v1.5.0") == %SemanticVersion{major: 1, minor: 5, patch: 0}
    end
  end
end
