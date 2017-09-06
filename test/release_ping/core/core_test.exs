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

      refute is_nil(software.uuid)
      assert software.name == "elixir"
      assert software.type == :language
      assert software.website == "https://elixir-lang.org"
      assert software.github == "elixir-lang/elixir"
      assert software.licenses == ["MIT"]
      assert software.release_retrieval == :github_release_poller

      assert {:ok, %Software{} = software} = Core.software_by_github("elixir-lang", "elixir")
      assert software.website == "https://elixir-lang.org"
      assert software.release_retrieval == :github_release_poller
    end

    @tag :integration
    test "updates github pollers" do
      assert {:ok, %Software{} = software} = Core.add_software(build(:software))

      Wait.until(fn -> (Core.github_release_pollers() |> length) > 0 end)

      [poller] = Core.github_release_pollers()

      assert poller.software_uuid == software.uuid
      assert poller.repository == "elixir-lang/elixir"
    end

    @tag :integration
    test "does not update github pollers when release_retrieval is different" do
      assert {:ok, %Software{}} = Core.add_software(build(:software, release_retrieval: nil))

      assert [] == Core.github_release_pollers()
    end
  end

  describe "publish release" do
    @tag :integration
    test "succeeds with valid data" do
      assert {:ok, %Software{} = software} = Core.add_software(build(:software))
      release = build(:release, %{software_uuid: software.uuid})

      assert {:ok, %Release{} = release} = Core.publish_release(release)

      assert release.software_uuid == software.uuid
      assert release.version_string == "v1.5.0"
      assert release.major_version == 1
      assert release.minor_version == 5
      assert release.patch_version == 0
      assert release.published_at == DateTime.from_naive!(~N[2017-07-25 07:27:16.000000], "Etc/UTC")
      assert release.seen_at == DateTime.from_naive!(~N[2017-07-25 07:30:00.000000], "Etc/UTC")
      assert release.release_notes_url == "https://github.com/elixir-lang/elixir/releases/tag/v1.5.0"
      assert release.pre_release == false
    end

    @tag :integration
    test "sets latest release to according software" do
      assert {:ok, %Software{} = software} = Core.add_software(build(:software))

      release = build(:release, %{software_uuid: software.uuid})
      assert {:ok, %Release{}} = Core.publish_release(release)

      {:ok, latest_release_uuid} = Wait.until(fn -> Repo.get(Software, software.uuid).latest_release_uuid end)

      refute is_nil(latest_release_uuid)
    end
  end
end
