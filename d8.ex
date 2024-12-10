defmodule D8 do
  def parse(s) do
    ls =
      s
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    m =
      for {l, i} <- Enum.with_index(ls) do
        for {c, j} <- Enum.with_index(l), do: {c, i, j}
      end
      |> List.flatten()
      |> Enum.group_by(fn t -> elem(t, 0) end, fn {_, i, j} -> {i, j} end)

    m
  end

  def pairs([]), do: []

  def pairs([x | tl]) do
    Stream.concat(
      Stream.map(tl, fn y -> {x, y} end),
      pairs(tl)
    )
  end

  # one of the antennas is twice as far away as the other
  # # at 1,3 a, 3, 4 and a,5, 5
  def is_antinode?({x, y}, {a, b}, {c, d}),
    do:
      (x == 2 * a - c and y == 2 * b - d) or
        (x == 2 * c - a and y == 2 * d - b)

  def is_antinode?(n, ant_pairs) do
    ant_pairs
    |> Enum.any?(fn {ant1, ant2} -> is_antinode?(n, ant1, ant2) end)
  end

  def part1(filename) do
    m =
      File.read!(filename)
      |> parse()

    list_of_ants =
      m
      |> Map.drop(["."])
      |> Map.values()

    ant_pairs =
      list_of_ants
      |> Enum.map(&pairs/1)

    antinodes =
      for node <- m |> Map.values() |> List.flatten() do
        {node,
         ant_pairs
         |> Enum.any?(fn ants -> is_antinode?(node, ants) end)}
      end

    antinodes
    |> Enum.count(fn {_, p} -> p end)
  end

  def is_updated_antinode?({x, y}, {a, b}, {c, d}) do
    cond do
      x == a -> y == b
      x == c -> y == d
      :else -> (b - d) / (a - c) == (b - y) / (a - x)
    end
  end

  def is_updated_antinode?(n, ant_pairs) do
    ant_pairs
    |> Enum.any?(fn {ant1, ant2} -> is_updated_antinode?(n, ant1, ant2) end)
  end

  def part2(filename) do
    m =
      File.read!(filename)
      |> parse()

    list_of_ants =
      m
      |> Map.drop(["."])
      |> Map.values()

    ant_pairs =
      list_of_ants
      |> Enum.map(&pairs/1)

    antinodes =
      for node <- m |> Map.values() |> List.flatten() do
        {node,
         ant_pairs
         |> Enum.any?(fn ants -> is_updated_antinode?(node, ants) end)}
      end

    antinodes
    |> Enum.count(fn {_, p} -> p end)
  end
end
