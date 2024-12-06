defmodule D4 do
  def transpose(l) do
    l |> Enum.zip_with(&Function.identity/1)
  end

  def to_matrix(s) do
    s |> String.split("\n") |> Enum.map(&String.graphemes/1)
  end

  def count(l), do: count(l, 0)
  def count([], num), do: num
  def count(["X", "M", "A", "S" | tl], num), do: count(["S" | tl], num + 1)
  def count(["S", "A", "M", "X" | tl], num), do: count(["X" | tl], num + 1)
  def count([_ | tl], num), do: count(tl, num)

  def count_diag(l), do: count_diag(l, 0)

  def count_diag([l1, l2, l3, l4 | _] = l, acc) do
    diags =
      List.zip([l1, l2 |> Enum.drop(1), l3 |> Enum.drop(2), l4 |> Enum.drop(3)]) ++
        List.zip([l1 |> Enum.drop(3), l2 |> Enum.drop(2), l3 |> Enum.drop(1), l4])

    c =
      diags
      # |> IO.inspect()
      |> Enum.filter(fn d -> d == {"X", "M", "A", "S"} or d == {"S", "A", "M", "X"} end)
      |> length()

    count_diag(tl(l), acc + c)
  end

  def count_diag(_, acc), do: acc

  def part1(m) do
    horizontal = m |> Enum.map(&D4.count/1) |> Enum.sum()
    vertical = m |> transpose |> Enum.map(&D4.count/1) |> Enum.sum()
    diag = count_diag(m)
    horizontal + vertical + diag
  end
end