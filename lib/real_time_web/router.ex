defmodule RealTimeWeb.Router do
  use RealTimeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RealTimeWeb do
    pipe_through :api
  end
end
