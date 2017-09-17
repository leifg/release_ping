defmodule ReleasePingWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      use ReleasePing.DataCase
      import ReleasePingWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint ReleasePingWeb.Endpoint
    end
  end


  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
