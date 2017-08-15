defmodule ReleasePing.CoreTest do
  use ReleasePing.DataCase
  import ReleasePing.Factory

  alias ReleasePing.Core
  alias ReleasePing.Core.Software

  alias ReleasePing.Wait

  describe "add software" do
    @tag :integration
    test "succeeds with valid data" do
      assert {:ok, %Software{} = software} = Core.add_software(build(:software))

      assert software.name == "elixir"
      assert software.website == "https://elixir-lang.org"
      assert software.github == "elixir-lang/elixir"
      assert software.licenses == ["MIT"]
    end
  end

  describe "publish release" do
    @tag :integration
    test "sets latest release to according software" do
      assert {:ok, %Software{} = software} = Core.add_software(build(:software))

      release = build(:release, %{software_uuid: software.uuid})
      assert :ok == Core.publish_release(release)

      latest_release_uuid = Wait.until(fn -> Repo.get(Software, software.uuid).latest_release_uuid end)

      refute is_nil(latest_release_uuid)
    end
  end
end
