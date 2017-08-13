defmodule ReleasePing.Core do
  alias ReleasePing.Core.Commands.AddSoftware
  alias ReleasePing.Core.Software
  alias ReleasePing.{Router, Wait, Repo}

  @doc """
  Add Software
  """
  @spec add_software(map) :: Software.t | {:error, any}
  def add_software(attrs \\ %{}) do
    uuid = UUID.uuid4()

    %AddSoftware{
      uuid: uuid,
      name: attrs[:name],
      website: attrs[:website],
      licenses: attrs[:licenses]
    }
      |> Router.dispatch()
      |> case do
        :ok -> Wait.until(fn -> Repo.get(Software, uuid) end)
        reply -> reply
      end
  end
end
