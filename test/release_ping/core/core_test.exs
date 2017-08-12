defmodule ReleasePing.CoreTest do
  use ExUnit.Case
  import ReleasePing.Factory


  describe "add software" do
    @tag :integration
    test "should succeed with valid data" do
      assert :ok == ReleasePing.Core.add_software(build(:software))
    end
  end
end
