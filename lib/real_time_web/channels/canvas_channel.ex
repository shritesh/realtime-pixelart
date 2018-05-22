defmodule RealTimeWeb.CanvasChannel do
  use RealTimeWeb, :channel
  alias RealTime.Canvas

  def join("canvas:" <> _topic, _payload, socket) do
    canvas = Canvas.new()
    {:ok, %{"canvas" => Canvas.list(canvas)}, assign(socket, :canvas, canvas)}
  end

  def handle_in(
        "pixel",
        %{"coordinate" => [x, y] = coordinate, "color" => [r, g, b] = color},
        socket
      ) do
    canvas = Canvas.put(socket.assigns.canvas, {x, y}, {r, g, b})

    broadcast(socket, "pixel", %{"coordinate" => coordinate, "color" => color})

    {:noreply, assign(socket, :canvas, canvas)}
  end
end
