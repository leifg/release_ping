defmodule ReleasePingWeb.SoftwareControllerTest do
  use ReleasePingWeb.ConnCase

  alias ReleasePing.Core

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:add_software]

    test "lists all software", %{conn: conn} do
      conn = get conn, software_path(conn, :index)
      assert Enum.count(json_response(conn, 200)) > 0
    end
  end

  defp add_software(_) do
    assert {:ok, software} = Core.add_software(build(:software))
    release = build(:release, %{software_uuid: software.uuid})

    assert {:ok, release} = Core.publish_release(release)
    {:ok, software: software, release: release}
  end
end
