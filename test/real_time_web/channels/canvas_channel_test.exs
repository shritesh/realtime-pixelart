defmodule RealTimeWeb.CanvasChannelTest do
  use RealTimeWeb.ChannelCase
  alias RealTimeWeb.CanvasChannel

  test "join/3 returns existing canvas" do
    assert {:ok, payload, _} = subscribe_and_join(socket(), CanvasChannel, "canvas:masterpiece")
    assert payload == %{"canvas" => []}
  end

  test "pixel with coordinates and colors broadcasts" do
    {:ok, _, socket} = subscribe_and_join(socket(), CanvasChannel, "canvas:masterpiece")

    payload = %{"coordinate" => [50, 50], "color" => [10, 10, 10]}

    push(socket, "pixel", payload)

    assert_broadcast("pixel", ^payload)
  end
end
