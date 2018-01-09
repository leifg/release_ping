defmodule ReleasePing.CoreTest do
  use ReleasePing.DataCase
  import ReleasePing.Factory

  alias ReleasePing.Core
  alias ReleasePing.Core.{Release, Software}

  alias ReleasePing.Wait

  describe "read software" do
    @tag :integration
    test "finds software by uuid" do
      assert {:ok, %Software{} = software} = Core.add_software(build(:software))

      read_software = Core.software_by_uuid(software.uuid)

      assert read_software.uuid == software.uuid
      assert read_software.name == software.name
      assert Regex.regex?(read_software.version_scheme)
    end
  end

  describe "add software" do
    @tag :integration
    test "succeeds with valid data" do
      assert {:ok, %Software{} = software} = Core.add_software(build(:software))

      refute is_nil(software.uuid)
      assert software.name == "elixir"
      assert software.type == :language
      assert software.slug == "elixir"
      assert software.website == "https://elixir-lang.org"
      assert software.github == "elixir-lang/elixir"
      assert software.licenses == ["MIT"]
      assert software.release_retrieval == :github_release_poller
    end

    test "fails for existing software" do
      assert {:ok, _software} = Core.add_software(build(:software))
      assert {:error, :validation_failure, [github: _]} = Core.add_software(build(:software))
    end

    @tag :integration
    test "updates github pollers" do
      assert {:ok, %Software{} = software} = Core.add_software(build(:software))

      Wait.until(fn -> Core.github_release_pollers() |> length > 0 end)

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

      assert release.published_at ==
               DateTime.from_naive!(~N[2017-07-25 07:27:16.000000], "Etc/UTC")

      assert release.seen_at == DateTime.from_naive!(~N[2017-07-25 07:30:00.000000], "Etc/UTC")

      assert release.release_notes_url ==
               "https://github.com/elixir-lang/elixir/releases/tag/v1.5.0"

      assert release.pre_release == false
    end
  end
end
