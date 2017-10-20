defmodule ReleasePing.Core.Aggregates.SoftwareTest do
  use ReleasePing.AggregateCase, aggregate: ReleasePing.Core.Aggregates.Software

  alias ReleasePing.Core.Commands.{
    ChangeLicenses,
    ChangeVersionScheme,
    CorrectName,
    CorrectReleaseNotesUrlTemplate,
    CorrectSoftwareType,
    CorrectWebsite
  }
  alias ReleasePing.Core.Events.{
    LicensesChanged,
    NameCorrected,
    ReleaseNotesUrlTemplateCorrected,
    ReleasePublished,
    SoftwareAdded,
    SoftwareTypeCorrected,
    VersionSchemeChanged, WebsiteCorrected
  }
  alias ReleasePing.Core.Version.VersionInfo

  describe "add software" do
    test "succeeds when valid" do
      uuid = UUID.uuid4()

      assertion_fun = fn(_aggregate, event, _error) ->
        assert event.__struct__ == SoftwareAdded
        assert event.uuid == uuid
        assert event.name == "elixir"
        assert event.type == :language
        assert event.version_scheme.source == "v(?<major>\\d+)\\.(?<minor>\\d+)\\.(?<patch>\\d+)(?:-(?<pre_release>.+))?"
        assert event.website == "https://elixir-lang.org"
        assert event.github == "elixir-lang/elixir"
        assert event.licenses == ["MIT"]
        assert event.release_retrieval == :github_release_poller
      end

      assert_events build(:add_software, uuid: uuid), assertion_fun
    end

    test "changes internal state of software correctly" do
      assertion_fun = fn(aggregate, event, _error) ->
        assert aggregate.__struct__ == ReleasePing.Core.Aggregates.Software
        assert aggregate.uuid == event.uuid
        assert aggregate.name == event.name
        assert aggregate.type == event.type
        assert aggregate.version_scheme.source == event.version_scheme.source
        assert aggregate.website == event.website
        assert aggregate.github == event.github
        assert aggregate.licenses == event.licenses
        assert aggregate.release_retrieval == event.release_retrieval
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

  describe "correct website" do
    setup [
      :add_software,
    ]

    test "succeeds when valid", %{software: software} do
      uuid = UUID.uuid4()
      new_website = "https://www.elixir-lang.org"

      assert_events software, %CorrectWebsite{uuid: uuid, software_uuid: software.uuid, website: new_website}, [
        %WebsiteCorrected{
          uuid: uuid,
          software_uuid: software.uuid,
          website: new_website,
        }
      ]
    end

    test "returns no events when website didn't change", %{software: software} do
      uuid = UUID.uuid4()
      new_website = software.website

      assert_events software, %CorrectWebsite{uuid: uuid, software_uuid: software.uuid, website: new_website}, []
    end
  end

  describe "correct release notes url template" do
    setup [
      :add_software,
    ]

    test "succeeds when valid", %{software: software} do
      uuid = UUID.uuid4()
      new_release_notes_url_template = "http://elixir-lang.org/version/<%= @version_string %>"

      assert_events software, %CorrectReleaseNotesUrlTemplate{uuid: uuid, software_uuid: software.uuid, release_notes_url_template: new_release_notes_url_template}, [
        %ReleaseNotesUrlTemplateCorrected{
          uuid: uuid,
          software_uuid: software.uuid,
          release_notes_url_template: new_release_notes_url_template,
        }
      ]
    end

    test "returns no events when website didn't change", %{software: software} do
      uuid = UUID.uuid4()
      new_release_notes_url_template = software.release_notes_url_template

      assert_events software, %CorrectReleaseNotesUrlTemplate{uuid: uuid, software_uuid: software.uuid, release_notes_url_template: new_release_notes_url_template}, []
    end
  end

  describe "change version_scheme" do
    setup [
      :add_software,
    ]

    test "succeeds when valid", %{software: software} do
      uuid = UUID.uuid4()
      new_version_scheme = "v(?<major>\\d+)\\.(?<minor>\\d+)\\.(?<patch>\\d+)(?:-(?<pre_release>.+))?(?:\\+(?<build_info>.+))?"

      assertion_fun = fn(_aggregate, event, _error) ->
        assert event.__struct__ == VersionSchemeChanged
        assert event.uuid == uuid
        assert event.software_uuid == software.uuid
        assert event.version_scheme.source == new_version_scheme
      end

      assert_events software, %ChangeVersionScheme{uuid: uuid, software_uuid: software.uuid, version_scheme: new_version_scheme}, assertion_fun
    end

    test "returns no events when version scheme didn't change", %{software: software} do
      uuid = UUID.uuid4()
      new_version_scheme = software.version_scheme

      assert_events software, %ChangeVersionScheme{uuid: uuid, software_uuid: software.uuid, version_scheme: new_version_scheme}, []
    end
  end

  describe "correct name" do
    setup [
      :add_software,
    ]

    test "succeeds when valid", %{software: software} do
      uuid = UUID.uuid4()
      new_name = "Elixir"

      assertion_fun = fn(_aggregate, event, _error) ->
        assert event.__struct__ == NameCorrected
        assert event.uuid == uuid
        assert event.software_uuid == software.uuid
        assert event.name == new_name
        assert event.reason == "test purposes"
      end

      assert_events software, %CorrectName{uuid: uuid, software_uuid: software.uuid, name: new_name, reason:  "test purposes"}, assertion_fun
    end

    test "returns no events when name didn't change", %{software: software} do
      uuid = UUID.uuid4()
      new_name = software.name

      assert_events software, %CorrectName{uuid: uuid, software_uuid: software.uuid, name: new_name, reason:  "test purposes"}, []
    end
  end

  describe "correct software type" do
    setup [
      :add_software,
    ]

    test "succeeds when valid", %{software: software} do
      uuid = UUID.uuid4()
      new_software_type = :application

      command = %CorrectSoftwareType{
        uuid: uuid,
        software_uuid: software.uuid,
        type: new_software_type,
        reason:  "test purposes"
      }

      event = %SoftwareTypeCorrected{
        uuid: uuid,
        software_uuid: software.uuid,
        type: new_software_type,
        reason: "test purposes"
      }

      assert_events software, command, [event]
    end

    test "returns no events when name didn't change", %{software: software} do
      uuid = UUID.uuid4()
      new_software_type = software.type

      assert_events software, %CorrectSoftwareType{uuid: uuid, software_uuid: software.uuid, type: new_software_type, reason:  "test purposes"}, []
    end
  end

  describe "publish release" do
    setup [
      :add_software,
    ]

    test "succeeds when valid", %{software: software} do
      uuid = UUID.uuid4()

      assert_events software, build(:publish_release, uuid: uuid, software_uuid: software.uuid), [
        %ReleasePublished{
          uuid: uuid,
          software_uuid: software.uuid,
          release_notes_url: "https://github.com/elixir-lang/elixir/releases/tag/v1.5.0",
          version_string: "v1.5.0",
          version_info: %VersionInfo{
            major: 1,
            minor: 5,
            patch: 0,
            published_at: "2017-07-25T07:27:16.000Z",
          },
          published_at: "2017-07-25T07:27:16.000Z",
          seen_at: "2017-07-25T07:30:00.000Z",
          pre_release: false,
        }
      ]
    end

    test "succeeds when release_notes_url is not set", %{software: software} do
      uuid = UUID.uuid4()

      command = build(
        :publish_release,
        uuid: uuid,
        software_uuid: software.uuid,
        release_notes_url: nil,
        version_string: "v1.5.2"
      )
      assert_events software, command, [
        %ReleasePublished{
          uuid: uuid,
          software_uuid: software.uuid,
          release_notes_url: "https://github.com/elixir-lang/elixir/releases/tag/v1.5.2",
          version_string: "v1.5.2",
          version_info: %VersionInfo{
            major: 1,
            minor: 5,
            patch: 2,
            published_at: "2017-07-25T07:27:16.000Z",  
          },
          published_at: "2017-07-25T07:27:16.000Z",
          seen_at: "2017-07-25T07:30:00.000Z",
          pre_release: false,
        }
      ]
    end

    test "does not return new event when release already exists", %{software: software} do
      command = build(:publish_release, uuid: UUID.uuid4(), software_uuid: software.uuid)
      {software, _events, _error} = execute(command, software)

      assert_events software, build(:publish_release, uuid: UUID.uuid4(), software_uuid: software.uuid), []
    end
  end

  defp add_software(_context) do
    uuid = UUID.uuid4()

    {software, _events, _error} = execute(build(:add_software, uuid: uuid))

    {:ok, %{software: software}}
  end
end
