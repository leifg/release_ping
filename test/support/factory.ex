defmodule ReleasePing.Factory do
  use ExMachina

  alias ReleasePing.Core.Events.SoftwareAdded
  alias ReleasePing.Core.Commands.AddSoftware

  def software_factory do
    %{
      name: "elixir",
      website: "https://elixir-lang.org",
      releases: [],
    }
  end

  def add_software_factory do
    struct(AddSoftware, build(:software))
  end
end
