defmodule ReleasePingWeb.SoftwareControllerTest do
  use ReleasePingWeb.ConnCase

  alias ReleasePing.Core
  alias ReleasePing.Api.Software
  alias ReleasePing.Core.Software, as: CoreSoftware
  alias ReleasePing.{Repo, Wait}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:add_software, :change_licenses]

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
      assert software["licenses"] == [%{"spdx_id" => "Apache-2.0", "name" => "Apache License 2.0"}]

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

  defp add_software(_context) do
    assert {:ok, core_software} = Core.add_software(build(:software))

    release = build(:release, %{software_uuid: core_software.uuid})
    assert {:ok, release} = Core.publish_release(release)

    pre_release = build(:pre_release, %{software_uuid: core_software.uuid})
    assert {:ok, pre_release} = Core.publish_release(pre_release)

    {:ok, software: core_software, releases: [release, pre_release]}
  end

  defp change_licenses(%{software: software} = context) do
    new_licenses = ["Apache-2.0"]
    Core.change_licenses(%{software_uuid: software.uuid, spdx_ids: new_licenses})

    :ok = Wait.until(fn ->
      software = Repo.get(Software, software.uuid)
      Enum.map(software.licenses, fn l -> l.spdx_id end) == new_licenses
    end)

    {:ok, %{context | software: Repo.get(CoreSoftware, software.uuid)}}
  end
end
