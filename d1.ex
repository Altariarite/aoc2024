defmodule D1 do
  def parse_lists() do
    File.read!("d1")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)
  end

  def distance(list) do
    list
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip_with(fn [a, b] -> abs(a - b) end)
    |> Enum.sum()
  end

  def similarity([l, r]) do
    freq = Enum.frequencies(r)

    l
    |> Enum.map(&(&1 * Map.get(freq, &1, 0)))
    |> Enum.sum()
  end
end
