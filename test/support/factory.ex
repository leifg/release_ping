defmodule ReleasePing.Factory do
  use ExMachina

  alias ReleasePing.Core.Commands.{AddSoftware, PublishRelease}

  def software_factory do
    elixir_factory()
  end

  def elixir_factory do
    %{
      name: "elixir",
      type: :language,
      slug: "elixir",
      version_scheme:
        "v(?<major>\\d+)\\.(?<minor>\\d+)\\.(?<patch>\\d+)(?:-(?<pre_release>.+))?(?:\\+(?<build_metadata>.+))?",
      release_notes_url_template:
        "https://github.com/elixir-lang/elixir/releases/tag/<%= @version_string %>",
      display_version_template:
        "<%= @major %>.<%= @minor %>.<%= @patch %><%= if @pre_release, do: \"-\#{@pre_release}\" %>",
      website: "https://elixir-lang.org",
      github: "elixir-lang/elixir",
      release_retrieval: :github_release_poller,
      licenses: ["MIT"]
    }
  end

  def erlang_factory do
    %{
      name: "erlang",
      type: :language,
      slug: "erlang",
      version_scheme:
        "OTP[-_](?<major>\\d+)\\.(?<minor>\\d+)(?:\\.(?<patch>\\d+))?(?:-(?<pre_release>.+))?",
      release_notes_url_template:
        "https://github.com/erlang/otp/releases/tag/<%= @version_string %>",
      display_version_template:
        "<%= @major %>.<%= @minor %>.<%= @patch %><%= if @pre_release, do: \"-\#{@pre_release}\" %>",
      website: "https://erlang.org",
      github: "erlang/otp",
      release_retrieval: :github_release_poller,
      licenses: ["Apache-2.0"]
    }
  end

  def release_factory do
    %{
      release_notes_url: "https://github.com/elixir-lang/elixir/releases/tag/v1.5.0",
      version_string: "v1.5.0",
      published_at: "2017-07-25T07:27:16.000Z",
      seen_at: "2017-07-25T07:30:00.000Z",
      pre_release: false
    }
  end

  def pre_release_factory do
    %{
      release_notes_url: "https://github.com/elixir-lang/elixir/releases/tag/v1.6.0-rc.1",
      version_string: "v1.6.0-rc.1",
      published_at: "2017-10-25T07:27:16.000Z",
      seen_at: "2017-10-13T15:03:13.000Z",
      pre_release: true
    }
  end

  def add_software_factory do
    struct(AddSoftware, build(:software))
  end

  def publish_release_factory do
    struct(PublishRelease, build(:release))
  end
end
