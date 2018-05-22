defmodule RealTime.Canvas do
  alias RealTime.Canvas

  @gridsize_x 800
  @gridsize_y 600
  @default_color {255, 255, 255}

  defstruct data: %{}

  defguard is_in_bounds(x, y) when x >= 0 and x < @gridsize_x and y >= 0 and y < @gridsize_y

  defguard is_valid_color(r, g, b)
           when r >= 0 and r < 256 and g >= 0 and g < 256 and b >= 0 and b <= 256

  def new do
    %Canvas{}
  end

  def get(%Canvas{data: data}, {x, y}) when is_in_bounds(x, y) do
    case Map.get(data, {x, y}) do
      nil -> @default_color
      color -> color
    end
  end

  def put(%Canvas{data: data} = canvas, {x, y} = coordinates, {r, g, b} = color)
      when is_in_bounds(x, y) and is_valid_color(r, g, b),
      do: %{canvas | data: Map.put(data, coordinates, color)}

  def list(%Canvas{data: data}), do: data
end