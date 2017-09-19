defmodule ReleasePingWeb.SoftwareControllerTest do
  use ReleasePingWeb.ConnCase

  alias ReleasePing.Core

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:add_software]

    test "returns list of software", %{conn: conn} do
      conn = get conn, software_path(conn, :index)
      assert Enum.count(json_response(conn, 200)) > 0
    end

    test "sets expected fields", %{conn: conn, software: core_software, releases: [release, pre_release]} do
      conn = get conn, software_path(conn, :index)
      assert [software] = json_response(conn, 200)


      assert software["id"] == core_software.uuid
      assert software["name"] == "elixir"
      assert software["website"] == "https://elixir-lang.org"
      assert software["licenses"] == [%{"spdx_id" => "MIT", "name" => "MIT License"}]

      assert software["latest_version_stable"] == %{
        "id"  => release.uuid,
        "name" => "1.5.0",
        "release_notes_url" => "https://github.com/elixir-lang/elixir/releases/tag/v1.5.0",
        "published_at" => "2017-07-25T07:27:16.000Z",
      }

      assert software["latest_version_unstable"] == %{
        "id"  => pre_release.uuid,
        "name" => "1.6.0-rc.1",
        "release_notes_url" => "https://github.com/elixir-lang/elixir/releases/tag/v1.6.0-rc.1",
        "published_at" => "2017-10-25T07:27:16.000Z",
      }
    end
  end

  defp fixture(:software) do
    build(:software)
  end

  defp add_software(_) do
    assert {:ok, core_software} = Core.add_software(fixture(:software))

    release = build(:release, %{software_uuid: core_software.uuid})
    assert {:ok, release} = Core.publish_release(release)

    pre_release = build(:pre_release, %{software_uuid: core_software.uuid})
    assert {:ok, pre_release} = Core.publish_release(pre_release)

    {:ok, software: core_software, releases: [release, pre_release]}
  end
end
