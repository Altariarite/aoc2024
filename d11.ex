defmodule D11 do
  def split(s) do
    l = String.length(s)
    fst = String.slice(s, 0..(div(l, 2) - 1))
    snd = String.slice(s, div(l, 2)..l) |> String.to_integer() |> Integer.to_string()
    [fst, snd]
  end

  def drop_0(m) do
    m
    |> Map.to_list()
    |> Enum.filter(fn {k, v} -> v != 0 end)
  end

  def update_m(keys, m) do
    keys |> Enum.reduce(m, fn {k, c}, m -> Map.update(m, k, c, fn v -> v + c end) end)
  end

  def blinks(m) do
    old_keys =
      m
      |> drop_0()

    new_keys =
      old_keys
      |> Enum.flat_map(fn {k, c} -> blink(k) |> Enum.map(fn k -> {k, c} end) end)

    new_map =
      old_keys
      |> Enum.reduce(m, fn {k, c}, m ->
        Map.update!(m, k, fn v ->
          v - c
        end)
      end)

    new_map =
      new_keys
      |> update_m(new_map)

    new_map
  end

  def blink(s) do
    cond do
      s == "0" ->
        ["1"]

      String.length(s) |> rem(2) == 0 ->
        split(s)

      :else ->
        i = s |> String.to_integer()
        [(i * 2024) |> Integer.to_string()]
    end
  end

  def part1(filename, times) do
    stones =
      File.read!(filename)
      |> String.split()
      |> Enum.frequencies()

    for i <- 1..times, reduce: stones do
      stones -> blinks(stones)
    end
  end
end
