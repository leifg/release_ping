defmodule ReleasePing.Core do
  alias ReleasePing.Core.Commands.AddSoftware
  alias ReleasePing.Router

  @doc """
  Create an author
  """
  def add_software(attrs \\ %{}) do
    uuid = UUID.uuid4()

    %AddSoftware{uuid: uuid, name: attrs[:name], website: attrs[:website]}
      |> Router.dispatch()
  end
end
