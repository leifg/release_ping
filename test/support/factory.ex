defmodule ReleasePing.Factory do
  use ExMachina

  alias ReleasePing.Core.Commands.AddSoftware

  def software_factory do
    %{
      name: "elixir",
      website: "https://elixir-lang.org",
      licenses: ["MIT"],
      releases: [],
    }
  end

  def release_factory do
    %{
      release_notes_url: "https://github.com/elixir-lang/elixir/releases/tag/v1.5.2",
      version: %{
        major: 1,
        minor: 5,
        patch: 0,
      },
      published_at: DateTime.from_naive!(~N[2017-07-25 07:27:16.000], "Etc/UTC"),
      pre_release: false,
    }
  end

  def add_software_factory do
    struct(AddSoftware, build(:software))
  end
end
