defmodule ReleasePing.CoreTest do
  use ReleasePing.DataCase
  import ReleasePing.Factory

  alias ReleasePing.Core
  alias ReleasePing.Core.{Release, Software}

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
    test "succeeds with valid data" do
      assert {:ok, %Software{} = software} = Core.add_software(build(:software))
      release = build(:release, %{software_uuid: software.uuid})

      assert {:ok, %Release{} = release} = Core.publish_release(release)

      assert release.software_uuid == software.uuid
      assert release.published_at == DateTime.from_naive!(~N[2017-07-25 07:27:16.000000], "Etc/UTC")
      assert release.release_notes_url == "https://github.com/elixir-lang/elixir/releases/tag/v1.5.0"
      assert release.pre_release == false

      Repo.get(Release, software.uuid)
    end

    @tag :integration
    test "sets latest release to according software" do
      assert {:ok, %Software{} = software} = Core.add_software(build(:software))

      release = build(:release, %{software_uuid: software.uuid})
      assert {:ok, %Release{}} = Core.publish_release(release)

      latest_release_uuid = Wait.until(fn -> Repo.get(Software, software.uuid).latest_release_uuid end)

      refute is_nil(latest_release_uuid)
    end
  end
end
