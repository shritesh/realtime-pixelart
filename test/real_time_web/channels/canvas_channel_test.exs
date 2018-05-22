defmodule RealTimeWeb.CanvasChannelTest do
  use RealTimeWeb.ChannelCase
  alias RealTime.Canvas
  alias RealTimeWeb.CanvasChannel

  test "join/3 returns existing canvas" do
    canvas = CanvasChannel.canvas(socket("masterpiece", %{topic: "masterpiece"}))
    Canvas.start_link(name: canvas)
    Canvas.put(canvas, {25, 25}, {30, 30, 30})
    Canvas.put(canvas, {30, 30}, {25, 25, 25})

    assert {:ok, payload, _} = subscribe_and_join(socket(), CanvasChannel, "canvas:masterpiece")

    assert payload == %{
             "canvas" => [
               %{"coordinate" => [25, 25], "color" => [30, 30, 30]},
               %{"coordinate" => [30, 30], "color" => [25, 25, 25]}
             ]
           }
  end

  test "pixel with coordinates and colors broadcasts" do
    {:ok, _, socket} = subscribe_and_join(socket(), CanvasChannel, "canvas:anothermasterpiece")

    payload = %{"coordinate" => [50, 50], "color" => [10, 10, 10]}

    push(socket, "pixel", payload)

    assert_broadcast("pixel", ^payload)
  end
end
