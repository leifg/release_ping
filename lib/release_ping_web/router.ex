defmodule ReleasePingWeb.Router do
  use ReleasePingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ReleasePingWeb do
    pipe_through :api
  end
end
