defmodule ReleasePing.Core.Version.Aggregates.SemanticVersionTest do
  use ExUnit.Case

  alias ReleasePing.Core.Version.SemanticVersion


  describe "default_version/0" do
    test "has expected value" do
      assert SemanticVersion.default_version_scheme().source == "(?<major>\\d+)\\.(?<minor>\\d+)(?:\\.(?<patch>\\d+))?(?:-(?<pre_release>.+))?"
    end
  end

  describe "from_map/1" do
    test "returns correct version for map" do
      version_map = %{
        "major" => 1,
        "minor" => 5,
        "patch" => 0,
        "pre_release" => "rc.2",
      }

      assert SemanticVersion.from_map(version_map) == %SemanticVersion{
        major: 1,
        minor: 5,
        patch: 0,
        pre_release: "rc.2",
      }
    end
  end

  describe "parse/2" do
    test "returns correct version for Elixir stable version" do
      version_scheme = SemanticVersion.default_version_scheme()
      assert SemanticVersion.parse("v1.5.2", version_scheme) == %SemanticVersion{
        major: 1,
        minor: 5,
        patch: 2,
        pre_release: nil,
      }
    end

    test "returns correct version for Elixir pre release version" do
      version_scheme = SemanticVersion.default_version_scheme()
      assert SemanticVersion.parse("v1.5.0-rc.2", version_scheme) == %SemanticVersion{
        major: 1,
        minor: 5,
        patch: 0,
        pre_release: "rc.2",
      }
    end

    test "returns correct version for Erlang major version" do
      version_scheme = SemanticVersion.default_version_scheme()
      assert SemanticVersion.parse("OTP-20.0", version_scheme) == %SemanticVersion{
        major: 20,
        minor: 0,
        patch: 0,
        pre_release: nil,
      }
    end

    test "returns correct version for Erlang pre release version" do
      version_scheme = SemanticVersion.default_version_scheme()
      assert SemanticVersion.parse("OTP-20.0-rc2", version_scheme) == %SemanticVersion{
        major: 20,
        minor: 0,
        patch: 0,
        pre_release: "rc2",
      }
    end
  end

  describe "parse/1" do
    test "returns correct version for plain version" do
      assert SemanticVersion.parse("1.5.0") == %SemanticVersion{major: 1, minor: 5, patch: 0}
    end

    test "returns correct version for tag version" do
      assert SemanticVersion.parse("v1.5.0") == %SemanticVersion{major: 1, minor: 5, patch: 0}
    end

    test "returns correct version for new OTP version" do
      assert SemanticVersion.parse("OTP-20.0.4") == %SemanticVersion{major: 20, minor: 0, patch: 4}
    end

    test "returns correct version for old OTP version" do
      assert SemanticVersion.parse("OTP_17.0-rc1") == %SemanticVersion{major: 17, minor: 0, patch: 0}
    end

    test "returns correct version for OTP branch version" do
      assert SemanticVersion.parse("OTP_17.5.6.1") == %SemanticVersion{major: 17, minor: 5, patch: 6}
    end
  end

  describe "name/1" do
    test "returns correct name for plain version" do
      assert SemanticVersion.name("1.5.0") == "1.5.0"
    end

    test "returns correct name for tag version" do
      assert SemanticVersion.name("v1.5.0") == "1.5.0"
    end

    test "returns correct name for new OTP version" do
      assert SemanticVersion.name("OTP-20.0.4") == "20.0.4"
    end

    test "returns correct name for old OTP version" do
      assert SemanticVersion.name("OTP_17.0-rc1") == "17.0.0-rc.1"
    end

    test "returns correct name for OTP branch version" do
      assert SemanticVersion.name("OTP_17.5.6.1") == "17.5.6.1"
    end
  end
end
