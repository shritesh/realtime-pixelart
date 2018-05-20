defmodule RealTimeWeb.Router do
  use RealTimeWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:put_secure_browser_headers)
  end

  scope "/", RealTimeWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end
end
