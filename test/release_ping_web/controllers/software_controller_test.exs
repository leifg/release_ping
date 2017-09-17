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

    test "sets expected fields", %{conn: conn} do
      conn = get conn, software_path(conn, :index)
      assert [software] = json_response(conn, 200)

      assert software["name"] == "elixir"
      assert software["website"] == "https://elixir-lang.org"
      assert software["licenses"] == [%{"spdx_id" => "MIT", "name" => "MIT License"}]
    end
  end

  defp fixture(:software) do
    build(:software)
  end

  defp add_software(_) do
    assert {:ok, software} = Core.add_software(fixture(:software))
    release = build(:release, %{software_uuid: software.uuid})

    assert {:ok, release} = Core.publish_release(release)
    {:ok, software: software, release: release}
  end
end
