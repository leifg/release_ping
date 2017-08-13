defmodule ReleasePing.CoreTest do
  use ReleasePing.DataCase
  import ReleasePing.Factory

  alias ReleasePing.Core
  alias ReleasePing.Core.Software

  describe "add software" do
    @tag :integration
    test "succeeds with valid data" do
      assert {:ok, %Software{} = software} = Core.add_software(build(:software))

      assert software.name == "elixir"
      assert software.website == "https://elixir-lang.org"
      assert software.licenses == ["MIT"]
    end
  end
end
