defmodule ReleasePing.Api do
  alias ReleasePing.Api.Software
  alias ReleasePing.Repo

  import Ecto.Query, only: [from: 2]

  def all_software() do
    Repo.all(from(s in Software, order_by: s.name))
  end
end