defmodule D9 do
  def parse(s), do: s |> String.graphemes() |> Enum.map(&String.to_integer/1)
  def expand(id, n), do: [id] |> Stream.cycle() |> Enum.take(n)

  def expand_s(l), do: expand_s(l, [], 0) |> Enum.reverse()
  def expand_s([], acc, _id), do: acc
  def expand_s([f], acc, id), do: expand(id, f) ++ acc

  # 12345 -> 0..111....22222
  def expand_s([f, space | tl], acc, id) do
    expand_s(tl, expand(".", space) ++ expand(id, f) ++ acc, id + 1)
  end

  def pos_map(l) do
    l |> Enum.with_index(fn element, index -> {index, element} end) |> Map.new()
  end

  @doc """
  0..111....22222
  02.111....2222.
  022111....222..
  0221112...22...
  02211122..2....
  022111222......

  """
  def fill_gap(m, l) do
    i = 0..l |> Enum.find(fn i -> Map.get(m, i) == "." end)
    {num, j} = biggest_number(m, l) |> IO.inspect()

    if j > i do
      m |> Map.put(i, num) |> Map.put(j, ".")
    else
      m
    end
  end

  def biggest_number(m, l) do
    i =
      l..0
      |> Enum.find(fn i -> Map.get(m, i) != "." end)

    {Map.get(m, i), i}
  end

  def fill_gaps(m, l) do
    new_m = fill_gap(m, l)

    if new_m == m do
      m
    else
      fill_gaps(new_m, l - 1)
    end
  end

  def part1(filename) do
    l = File.read!(filename) |> parse() |> expand_s()

    fill_gaps(l |> pos_map |> IO.inspect(), length(l) - 1)
    |> Map.to_list()
    |> Enum.filter(fn {_, n} -> n != "." end)
    |> Enum.reduce(0, fn {i, n}, acc -> i * n + acc end)
  end

  def blocks_map(l), do: blocks_map(l, [], 0, 0)

  def blocks_map([], acc, _, _), do: acc

  def blocks_map([f], acc, id, pos) do
    {m1, pos} = chunk_consec(id, f, pos)
    [m1 | acc]
  end

  def blocks_map([f, s | tl], acc, id, pos) do
    {m1, pos} = chunk_consec(id, f, pos)
    {m2, pos} = chunk_consec(".", s, pos)
    blocks_map(tl, [m2, m1 | acc], id + 1, pos)
  end

  # "."=>[1,2], "." => [5,6]
  def merge(acc, m) do
    Map.merge(acc, m, fn _k, acc, m -> [m | acc] end)
  end

  # 12345 -> {0=>[0], "."=>[1,2]}
  def chunk_consec(".", n, pos) do
    l = Stream.iterate(pos, &(&1 + 1)) |> Enum.take(n)
    {%{"." => l}, (l |> Enum.reverse() |> hd()) + 1}
  end

  def chunk_consec(id, n, pos) do
    l = Stream.iterate(pos, &(&1 + 1)) |> Enum.take(n)
    {%{id => l}, (l |> Enum.reverse() |> hd()) + 1}
  end

  @doc """
  00...111...2...333.44.5555.6666.777.888899
  0099.111...2...333.44.5555.6666.777.8888..
  0099.1117772...333.44.5555.6666.....8888..
  0099.111777244.333....5555.6666.....8888..
  00992111777.44.333....5555.6666.....8888..
  """
  def swap_sections(chunks, s) do
    l = length(s)
    res = chunks |> Enum.sort() |> Enum.find(fn c -> length(c) >= l end)

    cond do
      length(res) > l and hd(res) > hd(l) ->
        new = res |> Enum.drop(l)
        {res, chunks |> MapSet.delete(res) |> MapSet.put(new)}

      :else ->
        {s, chunks}
    end
  end

  def fill_chunk(m, l) do
    s = Map.get(m, l)
  end

  def part2(filename) do
    File.read!(filename) |> D9.parse() |> D9.blocks_map()
  end
end
