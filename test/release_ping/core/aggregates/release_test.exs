defmodule ReleasePing.Core.Aggregates.ReleaseTest do
  use ReleasePing.AggregateCase, aggregate: ReleasePing.Core.Aggregates.Release

  alias ReleasePing.Core.Events.ReleasePublished

  describe "publish release" do
    test "succeeds when valid" do
      uuid = UUID.uuid4()
      software_uuid = UUID.uuid4()

      assert_events build(:publish_release, uuid: uuid, software_uuid: software_uuid), [
        %ReleasePublished{
          uuid: uuid,
          software_uuid: software_uuid,
          release_notes_url: "https://github.com/elixir-lang/elixir/releases/tag/v1.5.0",
          version_string: "v1.5.0",
          published_at: "2017-07-25T07:27:16.000Z",
          seen_at: "2017-07-25T07:30:00.000Z",
          pre_release: false,
        }
      ]
    end
  end
end
