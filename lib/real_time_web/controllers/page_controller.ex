defmodule RealTimeWeb.PageController do
  use RealTimeWeb, :controller

  def index(conn, _) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> Plug.Conn.send_file(:ok, Path.join(:code.priv_dir(:real_time), ["static/", "index.html"]))
  end
end
