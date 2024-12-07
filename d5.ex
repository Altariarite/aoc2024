defmodule D5 do
  def parse_order(s) do
    s
    |> String.split("\n")
    |> Enum.take_while(fn s -> String.length(s) > 0 end)
    |> Enum.map(fn s -> String.split(s, "|") end)
    |> Enum.group_by(&hd/1, &Enum.at(&1, 1))
  end

  def parse_updates(s) do
    s
    |> String.split("\n")
    |> Enum.drop_while(fn s -> String.length(s) > 0 end)
    |> tl
    |> Enum.map(fn s -> String.split(s, ",") end)
  end

  def parse(s) do
    {parse_order(s), parse_updates(s)}
  end

  def correct_order?(l, orders) do
    l
    |> Enum.zip(tl(l))
    |> Enum.map(fn {fst, snd} -> snd in Map.get(orders, fst, []) end)
    |> Enum.all?()
  end

  def part1({orders, updates}) do
    updates
    |> Enum.filter(&correct_order?(&1, orders))
    |> IO.inspect()
    |> Enum.map(fn l -> l |> Enum.at(length(l) |> div(2)) end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end
end
