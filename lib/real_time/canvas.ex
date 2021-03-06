defmodule RealTime.Canvas do
  @gridsize_x 100
  @gridsize_y 75
  @default_color {255, 255, 255}

  defguard is_in_bounds(x, y) when x >= 0 and x < @gridsize_x and y >= 0 and y < @gridsize_y

  defguard is_valid_color(r, g, b)
           when r >= 0 and r < 256 and g >= 0 and g < 256 and b >= 0 and b <= 256

  def start_link(opts \\ []) do
    Agent.start(fn -> %{} end, opts)
  end

  def get(canvas, {x, y}) when is_in_bounds(x, y) do
    case Agent.get(canvas, &Map.get(&1, {x, y})) do
      nil -> @default_color
      color -> color
    end
  end

  def put(canvas, {x, y} = coordinates, {r, g, b} = color)
      when is_in_bounds(x, y) and is_valid_color(r, g, b),
      do: Agent.update(canvas, &Map.put(&1, coordinates, color))

  def list(canvas), do: Agent.get(canvas, & &1)
end
