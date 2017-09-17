defmodule ReleasePing.Api do
  alias ReleasePing.Api.Software
  alias ReleasePing.Repo

  def all_software() do
    Repo.all(Software)
  end
end