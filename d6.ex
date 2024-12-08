defmodule D6 do
  defmodule World do
    defstruct [:boundary, :obstacles, :guard, :trail, :direction, :started]
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
      obstacles: MapSet.new(get_obstacles(pos)),
      boundary: get_boundary(pos),
      guard: get_guard(pos),
      trail: MapSet.new([get_guard(pos)]),
      direction: :up,
      started: false
    }
  end

  def world_to_string(%World{} = world) do
    {max_x, max_y} = world.boundary

    for x <- 0..max_x do
      for y <- 0..max_y do
        cond do
          {x, y} == world.guard and world.direction == :up -> "^"
          {x, y} == world.guard and world.direction == :right -> ">"
          {x, y} == world.guard and world.direction == :down -> "v"
          {x, y} == world.guard and world.direction == :left -> "<"
          {x, y} in world.trail -> "X"
          {x, y} in world.obstacles -> "#"
          true -> "."
        end
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
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

  def in_boundary?({x, y}, {i, j}), do: 0 <= x and x <= i and 0 <= y and y <= j

  def move_guard(w) do
    # IO.inspect(w)
    forward = step_forward(w.guard, w.direction)

    cond do
      not in_boundary?(forward, w.boundary) ->
        w.trail

      forward in w.obstacles ->
        move_guard(%World{w | direction: turn_right(w.direction)})

      :else ->
        move_guard(%World{w | guard: forward, trail: MapSet.put(w.trail, forward)})
    end
  end

  def part1() do
    File.read!("d6") |> s_to_world() |> move_guard() |> MapSet.size()
  end

  def move_guard_detect_loop(w) do
    # Use a MapSet to track unique states
    # A state is a combination of guard position, direction, and trail
    states = MapSet.new()
    move_guard_detect_loop(w, states)
  end

  # looping if we come back to a position
  # and facing the same direction, but have moved

  def move_guard_detect_loop(w, states) do
    current_state = {w.guard, w.direction}

    if states |> MapSet.member?(current_state) and
         w.started do
      # IO.puts(w |> world_to_string)
      # IO.puts("\n\n")
      :loop
    else
      forward = step_forward(w.guard, w.direction)
      updated_states = MapSet.put(states, current_state)

      if not w.started do
        # IO.puts("Start world: ")
        # IO.puts(w |> world_to_string)
        # IO.puts("\n\n")
      else
        # IO.puts(w |> world_to_string)
        # IO.puts("\n\n")
      end

      cond do
        not in_boundary?(forward, w.boundary) ->
          # IO.puts(w |> world_to_string)
          # IO.puts("\n\n")
          :finished

        forward in w.obstacles ->
          move_guard_detect_loop(
            %World{w | direction: turn_right(w.direction), started: true},
            updated_states
          )

        :else ->
          move_guard_detect_loop(
            %World{w | guard: forward, trail: MapSet.put(w.trail, forward), started: true},
            updated_states
          )
      end
    end
  end

  def run_test(filename) do
    w = File.read!(filename) |> s_to_world()
    move_guard_detect_loop(w)
  end

  def part2() do
    start_world = File.read!("d6") |> s_to_world()
    {x, y} = start_world.boundary

    worlds =
      for i <- 0..x,
          do:
            for(
              j <- 0..y,
              do: %World{start_world | obstacles: MapSet.put(start_world.obstacles, {i, j})}
            )

    worlds
    |> List.flatten()
    |> Enum.with_index()
    |> Parallel.pmap(fn {w, i} -> {move_guard_detect_loop(w), i} |> IO.inspect() end)
    |> Enum.count(fn {r, _} -> r == :loop end)
  end
end

defmodule Parallel do
  def pmap(collection, func) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.map(&Task.await/1)
  end
end
