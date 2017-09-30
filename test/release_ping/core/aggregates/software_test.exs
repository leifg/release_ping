defmodule ReleasePing.Core.Aggregates.SoftwareTest do
  use ReleasePing.AggregateCase, aggregate: ReleasePing.Core.Aggregates.Software


  alias ReleasePing.Core.Commands.ChangeLicenses
  alias ReleasePing.Core.Events.{LicensesChanged, SoftwareAdded}

  describe "add software" do
    test "succeeds when valid" do
      uuid = UUID.uuid4()

      assert_events build(:add_software, uuid: uuid), [
        %SoftwareAdded{
          uuid: uuid,
          name: "elixir",
          website: "https://elixir-lang.org",
          github: "elixir-lang/elixir",
          type: :language,
          licenses: ["MIT"],
          release_retrieval: :github_release_poller,
        }
      ]
    end
  end

  describe "change license" do
    setup [
      :add_software,
    ]

    test "succeeds when valid", %{software: software} do
      uuid = UUID.uuid4()
      new_licenses = ["Apache-2.0"]

      assert_events software, %ChangeLicenses{uuid: uuid, software_uuid: software.uuid, licenses: new_licenses}, [
        %LicensesChanged{
          uuid: uuid,
          software_uuid: software.uuid,
          licenses: new_licenses,
        }
      ]
    end

    test "returns no events when licenses didn't change", %{software: software} do
      uuid = UUID.uuid4()
      new_licenses = software.licenses

      assert_events software, %ChangeLicenses{uuid: uuid, software_uuid: software.uuid, licenses: new_licenses}, []
    end
  end

  defp add_software(_context) do
    uuid = UUID.uuid4()

    {software, _events, _error} = execute(build(:add_software, uuid: uuid))

    [
      software: software,
    ]
  end
end
