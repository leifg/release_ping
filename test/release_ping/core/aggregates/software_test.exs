defmodule ReleasePing.Core.Aggregates.SoftwareTest do
  use ReleasePing.AggregateCase, aggregate: ReleasePing.Core.Aggregates.Software


  alias ReleasePing.Core.Commands.{ChangeLicenses, ChangeVersionScheme}
  alias ReleasePing.Core.Events.{LicensesChanged, SoftwareAdded, VersionSchemeChanged}

  describe "add software" do
    test "succeeds when valid" do
      uuid = UUID.uuid4()

      assert_events build(:add_software, uuid: uuid), [
        %SoftwareAdded{
          uuid: uuid,
          name: "elixir",
          type: :language,
          version_scheme: "v(?<major>\\d+)\\.(?<minor>\\d+)\\.(?<patch>\\d+)(?:-(?<pre_release>.+))?",
          website: "https://elixir-lang.org",
          github: "elixir-lang/elixir",
          licenses: ["MIT"],
          release_retrieval: :github_release_poller,
        }
      ]
    end

    test "changes internal state of software correctly" do
      assertion_fun = fn(aggregate, event, _error) ->
        assert aggregate == %ReleasePing.Core.Aggregates.Software{
          uuid: event.uuid,
          name: event.name,
          type: event.type,
          version_scheme: Regex.compile!(event.version_scheme),
          website: event.website,
          github: event.github,
          licenses: event.licenses,
          release_retrieval: event.release_retrieval,
        }
      end

      command = build(:add_software, uuid: UUID.uuid4())

      assert_events(%ReleasePing.Core.Aggregates.Software{}, command, assertion_fun)
    end

    test "raises error on invalid version_scheme" do
      uuid = UUID.uuid4()
      version_scheme = "(invalid"

      assert_error build(:add_software, uuid: uuid, version_scheme: version_scheme), {:error, {:regex_error, "'missing )' at position 8"}}
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

  describe "change version_scheme" do
    setup [
      :add_software,
    ]

    test "succeeds when valid", %{software: software} do
      uuid = UUID.uuid4()
      new_version_scheme = "v(?<major>\\d+)\\.(?<minor>\\d+)\\.(?<patch>\\d+)(?:-(?<pre_release>.+))?(?:\\+(?<build_info>.+))?"

      assert_events software, %ChangeVersionScheme{uuid: uuid, software_uuid: software.uuid, version_scheme: new_version_scheme}, [
        %VersionSchemeChanged{
          uuid: uuid,
          software_uuid: software.uuid,
          version_scheme: new_version_scheme,
        }
      ]
    end

    test "returns no events when version scheme didn't change", %{software: software} do
      uuid = UUID.uuid4()
      new_version_scheme = software.version_scheme

      assert_events software, %ChangeVersionScheme{uuid: uuid, software_uuid: software.uuid, version_scheme: new_version_scheme}, []
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
