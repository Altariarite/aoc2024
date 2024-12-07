defmodule D6 do
  defmodule World do
    defstruct [:boundary, :obstacles, :guard, :trail, :direction]
  end

  def s_to_world(s) do
    ls =
      s
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    pos =
      for {l, i} <- Enum.with_index(ls) do
        for {c, j} <- Enum.with_index(l), do: {c, i, j}
      end
      |> List.flatten()

    %World{
      obstacles: get_obstacles(pos),
      boundary: get_boundary(pos),
      guard: get_guard(pos),
      trail: MapSet.new([get_guard(pos)]),
      direction: :up
    }
  end

  def pos({_, i, j}), do: {i, j}

  def get_boundary(l) do
    l
    |> Enum.at(-1)
    |> pos
  end

  def get_obstacles(l),
    do:
      l
      |> Enum.filter(fn {c, _, _} -> c == "#" end)
      |> Enum.map(&pos/1)

  def get_guard(l),
    do:
      l
      |> Enum.find(fn {c, _, _} -> c == "^" end)
      |> pos

  def step_forward({x, y}, direction) do
    case direction do
      :up -> {x - 1, y}
      :down -> {x + 1, y}
      :right -> {x, y + 1}
      :left -> {x, y - 1}
    end
  end

  def turn_right(d) do
    case(d) do
      :up -> :right
      :right -> :down
      :down -> :left
      :left -> :up
    end
  end

  def turn(guard, d, obstacles) do
    if step_forward(guard, d) in obstacles do
      turn(guard, turn_right(d), obstacles)
    else
      d
    end
  end

  def in_boundary?({x, y}, {i, j}), do: 0 <= x and x <= i and 0 <= y and y <= j

  def move_guard(w) do
    # IO.inspect(w)
    forward = step_forward(w.guard, w.direction)

    cond do
      not in_boundary?(forward, w.boundary) ->
        w.trail

      forward in w.obstacles ->
        move_guard(%World{w | direction: turn(w.guard, w.direction, w.obstacles)})

      :else ->
        move_guard(%World{w | guard: forward, trail: MapSet.put(w.trail, forward)})
    end
  end

  def part1() do
    File.read!("d6") |> s_to_world() |> move_guard() |> MapSet.size()
  end
end
