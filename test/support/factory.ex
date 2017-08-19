defmodule ReleasePing.Factory do
  use ExMachina

  alias ReleasePing.Core.Commands.AddSoftware

  def software_factory do
    %{
      name: "elixir",
      website: "https://elixir-lang.org",
      github: "elixir-lang/elixir",
      release_retrieval: :github_release_poller,
      licenses: ["MIT"],
    }
  end

  def release_factory do
    %{
      release_notes_url: "https://github.com/elixir-lang/elixir/releases/tag/v1.5.0",
      version_string: "v1.5.0",
      published_at: "2017-07-25T07:27:16.000Z",
      seen_at: "2017-07-25T07:30:00.000Z",
      pre_release: false,
    }
  end

  def add_software_factory do
    struct(AddSoftware, build(:software))
  end
end
