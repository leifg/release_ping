defmodule ReleasePing.Core.Version.Aggregates.VersionInfoTest do
  use ExUnit.Case

  alias ReleasePing.Core.Version.VersionInfo


  describe "default_version/0" do
    test "has expected value" do
      assert VersionInfo.default_version_scheme().source == "(?<major>\\d+)\\.(?<minor>\\d+)(?:\\.(?<patch>\\d+))?(?:-(?<pre_release>.+))?"
    end
  end

  describe "parse/2" do
    test "returns correct version for Elixir stable version" do
      version_scheme = VersionInfo.default_version_scheme()
      assert VersionInfo.parse("v1.5.2", version_scheme) == %VersionInfo{
        major: 1,
        minor: 5,
        patch: 2,
        pre_release: nil,
      }
    end

    test "returns correct version for Elixir pre release version" do
      version_scheme = VersionInfo.default_version_scheme()
      assert VersionInfo.parse("v1.5.0-rc.2", version_scheme) == %VersionInfo{
        major: 1,
        minor: 5,
        patch: 0,
        pre_release: "rc.2",
      }
    end

    test "returns correct version for Erlang major version" do
      version_scheme = VersionInfo.default_version_scheme()
      assert VersionInfo.parse("OTP-20.0", version_scheme) == %VersionInfo{
        major: 20,
        minor: 0,
        patch: 0,
        pre_release: nil,
      }
    end

    test "returns correct version for Erlang pre release version" do
      version_scheme = VersionInfo.default_version_scheme()
      assert VersionInfo.parse("OTP-20.0-rc2", version_scheme) == %VersionInfo{
        major: 20,
        minor: 0,
        patch: 0,
        pre_release: "rc2",
      }
    end
  end

  @erlang_version_scheme ~r/OTP[-_](?<major>\d+)\.(?<minor>\d+)(?:\.(?<patch>\d+))?(?:-(?<pre_release>.+))?/

  describe "valid?" do
    test "returns true for release version" do
      assert VersionInfo.valid?("OTP-20.0.1", @erlang_version_scheme)
    end

    test "returns true for release version without patch version" do
      assert VersionInfo.valid?("OTP-20.0", @erlang_version_scheme)
    end

    test "returns false for weird erlang release" do
      refute VersionInfo.valid?("OTP_R16B03-1", @erlang_version_scheme)
    end
  end

  describe "pre_release?/2" do
    test "returns false for release version" do
      refute VersionInfo.pre_release?("OTP-20.0.1", @erlang_version_scheme)
    end

    test "returns true for pre_release version" do
      assert VersionInfo.pre_release?("OTP-20.0-rc2", @erlang_version_scheme)
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

      assert VersionInfo.from_map(version_map) == %VersionInfo{
        major: 1,
        minor: 5,
        patch: 0,
        pre_release: "rc.2",
      }
    end
  end
end
