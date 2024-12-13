defmodule D12 do
  alias ElixirSense.Core.Compiler.Map

  def parse(s) do
    ls =
      s
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    for {l, i} <- Enum.with_index(ls) do
      for {c, j} <- Enum.with_index(l), do: {i, j, c}
    end
    |> List.flatten()
    |> Enum.group_by(fn {_i, _j, c} -> c end, fn {i, j, _c} -> {i, j} end)
  end

  def dfs(node, s) do
    do_dfs([node], s, MapSet.new())
  end

  defp do_dfs([], _s, visited), do: visited

  defp do_dfs([vertex | rest], s, visited) do
    if vertex in visited do
      do_dfs(rest, s, visited)
    else
      {i, j} = vertex

      next_nodes =
        [{i + 1, j}, {i - 1, j}, {i, j + 1}, {i, j - 1}]
        |> Enum.filter(fn pos -> pos in s end)
        |> Enum.reject(fn pos -> pos in visited end)

      visited = MapSet.put(visited, vertex)

      do_dfs(next_nodes ++ rest, s, visited)
    end
  end

  def groups(s), do: groups(s, MapSet.new())

  def groups(s, acc) do
    case s |> Enum.take(1) do
      [] ->
        acc

      [seed] ->
        group = dfs(seed, s)
        groups(s |> MapSet.difference(group), acc |> MapSet.put(group))
    end
  end

  @doc """
  connected on 4 sides -> 0
  3 -> 1
  2 -> 2
  1 -> 3
  0 -> 4
  """
  def perimeter({i, j}, s) do
    [{i + 1, j}, {i - 1, j}, {i, j + 1}, {i, j - 1}]
    |> Enum.count(fn pos -> pos not in s end)
  end

  def perimeters(l) do
    l
    |> Enum.reduce(0, fn pos, acc -> perimeter(pos, l) + acc end)
  end

  def price(region) do
    MapSet.size(region) * perimeters(region)
  end

  def part1(f) do
    m =
      File.read!(f)
      |> parse()

    m =
      for {k, v} <- m,
          into: %{},
          do: {k, v |> MapSet.new() |> groups}

    # |> IO.inspect()

    m
    |> Enum.flat_map(fn {_k, groups} -> Enum.map(groups, &price/1) end)
    |> Enum.sum()
  end

  def count_sides(coords) do
    Enum.reduce(coords, 0, fn coord, total_sides ->
      total_sides + count_corner(coord, coords)
    end)

    # |> IO.inspect()
  end

  def is_corner?({i, j}, l, s) do
    diff = l |> MapSet.difference(s)

    case MapSet.size(diff) do
      3 ->
        true

      1 ->
        [{x, y}] = Enum.take(diff, 1)
        x != i and y != j

      2 ->
        Enum.take(diff, 2) |> Enum.all?(fn {x, y} -> x == i or y == j end)

      0 ->
        false
    end
  end

  def count_corner({i, j}, s) do
    directions = %{
      :topleft => [{-1, -1}, {-1, 0}, {0, -1}],
      :topright => [{-1, 0}, {-1, 1}, {0, 1}],
      :bottomleft => [{0, -1}, {1, -1}, {1, 0}],
      :bottomright => [{1, 0}, {1, 1}, {0, 1}]
    }

    directions
    |> Enum.map(fn {k, v} ->
      {k, v |> Enum.map(fn {row, col} -> {i + row, j + col} end)}
    end)
    |> Enum.filter(fn {k, v} -> is_corner?({i, j}, MapSet.new(v), s) end)
    |> Enum.map(fn {k, v} -> k end)
    |> IO.inspect()
    |> Enum.count()
  end

  def part2_price(region) do
    count_sides(region) * MapSet.size(region)
  end

  def part2(f) do
    m =
      File.read!(f)
      |> parse()

    # |> IO.inspect()

    m =
      for {k, v} <- m,
          into: %{},
          do: {k, v |> MapSet.new() |> groups}

    m
    |> Enum.flat_map(fn {_k, groups} -> Enum.map(groups, &part2_price/1) end)
    |> Enum.sum()
  end
end
