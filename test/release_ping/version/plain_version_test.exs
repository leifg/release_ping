defmodule ReleasePing.Core.Version.Aggregates.PlainVersionTest do
  use ExUnit.Case

  alias ReleasePing.Core.Version.PlainVersion
  alias ReleasePing.Core.Version.SemanticVersion

  describe "parse/1" do
    test "it parses version string correctly" do
      assert PlainVersion.parse("1.5.0") == %SemanticVersion{major: 1, minor: 5, patch: 0}
    end
  end
end
