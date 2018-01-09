defmodule ReleasePingWeb.Router do
  use ReleasePingWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ReleasePingWeb do
    pipe_through(:api)

    get("/software", SoftwareController, :index)
  end
end
