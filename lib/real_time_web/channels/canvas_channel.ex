defmodule RealTimeWeb.CanvasChannel do
  use RealTimeWeb, :channel
  alias RealTime.Canvas

  def join("canvas:" <> topic, _payload, socket) do
    socket = assign(socket, :topic, topic)
    Canvas.start_link(name: canvas(socket))
    {:ok, %{"canvas" => []}, socket}
  end

  def canvas(socket), do: {:via, Registry, {RealTime.CanvasRegistry, socket.assigns.topic}}

  def handle_in(
        "pixel",
        %{"coordinate" => [x, y] = coordinate, "color" => [r, g, b] = color},
        socket
      ) do
    Canvas.put(canvas(socket), {x, y}, {r, g, b})
    broadcast(socket, "pixel", %{"coordinate" => coordinate, "color" => color})

    {:noreply, socket}
  end
end
