defmodule ReleasePing.Api.VersionUtilsTest do
  use ExUnit.Case

  alias ReleasePing.Api.VersionUtils
  alias ReleasePing.Api.Software.Version

  describe "compare/2" do
    test "returns :gt for newer major version" do
      version1 = %Version{
        major: 1,
        minor: 0,
        patch: 0,
        published_at: to_datetime("2017-07-25T07:47:11Z")
      }

      version2 = %Version{
        major: 0,
        minor: 9,
        patch: 9,
        published_at: to_datetime("2017-06-30T13:21:23Z")
      }

      assert VersionUtils.compare(version1, version2) == :gt
    end

    test "returns :lt for older minor version" do
      version1 = %Version{
        major: 1,
        minor: 0,
        patch: 0,
        published_at: to_datetime("2017-07-25T07:47:11Z")
      }

      version2 = %Version{
        major: 1,
        minor: 1,
        patch: 0,
        published_at: to_datetime("2017-07-26T09:46:41Z")
      }

      assert VersionUtils.compare(version1, version2) == :lt
    end

    test "returns :eq for same version" do
      version1 = %Version{
        major: 1,
        minor: 0,
        patch: 0,
        published_at: to_datetime("2017-07-25T07:47:11Z")
      }

      version2 = %Version{
        major: 1,
        minor: 0,
        patch: 0,
        published_at: to_datetime("2017-07-25T07:47:11Z")
      }

      assert VersionUtils.compare(version1, version2) == :eq
    end

    test "returns :gt for later released version" do
      version1 = %Version{
        major: 1,
        minor: 0,
        patch: 0,
        published_at: to_datetime("2017-07-26T09:46:41Z")
      }

      version2 = %Version{
        major: 1,
        minor: 0,
        patch: 0,
        published_at: to_datetime("2017-06-30T13:21:23Z")
      }

      assert VersionUtils.compare(version1, version2) == :gt
    end
  end

  defp to_datetime(iso8601_string) do
    {:ok, datetime, 0} = DateTime.from_iso8601(iso8601_string)
    datetime
  end
end
