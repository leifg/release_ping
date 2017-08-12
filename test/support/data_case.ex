defmodule ReleasePing.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias ReleasePing.Repo

      import Ecto
      import ReleasePing.Factory
      import ReleasePing.DataCase
    end
  end

  setup _tags do
    ReleasePing.Storage.reset!()

    :ok
  end
end
