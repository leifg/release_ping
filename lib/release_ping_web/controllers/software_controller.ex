defmodule ReleasePingWeb.SoftwareController do
  use ReleasePingWeb, :controller

  alias ReleasePing.Api

  action_fallback(ReleasePingWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.json", software: Api.all_software())
  end
end
