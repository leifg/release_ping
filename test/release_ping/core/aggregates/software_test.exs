defmodule ReleasePing.Core.Aggregates.SoftwareTest do
  use ReleasePing.AggregateCase, aggregate: ReleasePing.Core.Aggregates.Software

  alias ReleasePing.Core.Events.SoftwareAdded

  describe "add software" do
    test "succeeds when valid" do
      uuid = UUID.uuid4()

      assert_events build(:add_software, uuid: uuid), [
        %SoftwareAdded{
          uuid: uuid,
          name: "elixir",
          website: "https://elixir-lang.org",
        }
      ]
    end
  end
end
