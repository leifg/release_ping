defmodule ReleasePingWeb.SoftwareController do
  use ReleasePingWeb, :controller

  alias ReleasePing.Core

  action_fallback ReleasePingWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.json", software: Core.all_software())
  end
end
