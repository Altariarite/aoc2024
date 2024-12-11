defmodule D10 do
  def parse(s) do
    ls =
      s
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    pos =
      for {l, i} <- Enum.with_index(ls) do
        for {c, j} <- Enum.with_index(l), do: {i, j, c}
      end
      |> List.flatten()

    pos_map =
      Enum.reduce(pos, %{}, fn {i, j, c}, m ->
        Map.put(
          m,
          {i, j},
          if c == "." do
            -1
          else
            String.to_integer(c)
          end
        )
      end)

    starting_pos = Enum.group_by(pos, fn {_, _, c} -> c end, fn {i, j, _c} -> {i, j} end)
    {pos_map, starting_pos |> Map.get("0")}
  end

  def uphill({i, j} = start, pos_map) do
    h = Map.get(pos_map, start)

    if h == 9 do
      [start]
    else
      [{i + 1, j}, {i, j + 1}, {i - 1, j}, {i, j - 1}]
      |> Enum.filter(
        &(Map.has_key?(pos_map, &1) and
            Map.get(pos_map, &1) == h + 1)
      )
    end
  end

  def trail({pos_map, acc}) do
    new = acc |> Enum.flat_map(fn p -> uphill(p, pos_map) end)

    if new == acc do
      acc |> Enum.uniq()
    else
      trail({pos_map, new})
    end
  end

  def part1(filename) do
    {pos_map, starts} =
      File.read!(filename)
      |> D10.parse()

    starts
    |> Enum.map(fn s -> trail({pos_map, [s]}) end)
    |> Enum.map(&length/1)
    |> Enum.sum()
  end

  def distinct_trail({pos_map, acc}) do
    new = acc |> Enum.flat_map(fn p -> uphill(p, pos_map) end)

    if new == acc do
      acc
    else
      distinct_trail({pos_map, new})
    end
  end

  def part2(filename) do
    {pos_map, starts} =
      File.read!(filename)
      |> D10.parse()

    starts
    |> Enum.map(fn s -> distinct_trail({pos_map, [s]}) end)
    |> Enum.map(&length/1)
    |> Enum.sum()
  end
end
