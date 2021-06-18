defmodule RealTime.Canvas do
  @gridsize_x 100
  @gridsize_y 75
  @default_color {255, 255, 255}

  @moduledoc """
  A `Canvas` is a process holding a grid of #{@gridsize_x} by #{@gridsize_y} pixels with individual colors.
  The color format is {r,g,b} with values between 0 and 255.

  The default color is #{inspect @default_color}.
  """

  defguard in_bounds?(x, y) when x >= 0 and x < @gridsize_x and y >= 0 and y < @gridsize_y

  defguard valid_color?(r, g, b) when r in 0..255 and g in 0..255 and b in 0..255

  @doc """
  Starts the `Canvas` process.
  """
  def start_link(opts \\ []) do
    Agent.start(fn -> %{} end, opts)
  end

  @doc """
  Returns the color of the pixel of the given coordinates.
  The coordinates must be in bounds.
  """
  def get(canvas, {x, y}) when in_bounds?(x, y) do
    case Agent.get(canvas, &Map.get(&1, {x, y})) do
      nil -> @default_color
      color -> color
    end
  end

  @doc """
  Puts the given color at the given pixel coordinates.
  The coordinates must be in bounds.
  """
  def put(canvas, {x, y} = coordinates, {r, g, b} = color)
      when in_bounds?(x, y) and valid_color?(r, g, b),
      do: Agent.update(canvas, &Map.put(&1, coordinates, color))


  @doc """
  Returns a map of non-default pixels with {r,g,b} color values keyed by {x,y} coordinates.
  """
  def list(canvas), do: Agent.get(canvas, & &1)
end
