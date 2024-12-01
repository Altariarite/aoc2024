defmodule D1 do
  def d1() do
    {:ok, contents} = File.read("d1")

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip_with(fn [a, b] -> abs(String.to_integer(b) - String.to_integer(a)) end)
    |> Enum.sum()
  end
end
