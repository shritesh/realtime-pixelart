defmodule RealTimeWeb.CanvasChannel do
  use RealTimeWeb, :channel

  def join("canvas:" <> _topic, _payload, socket) do
    {:ok, %{"canvas" => []}, socket}
  end

  def handle_in(
        "pixel",
        %{"coordinate" => [_x, _y] = coordinate, "color" => [_r, _g, _b] = color},
        socket
      ) do
    broadcast(socket, "pixel", %{"coordinate" => coordinate, "color" => color})

    {:noreply, socket}
  end
end
