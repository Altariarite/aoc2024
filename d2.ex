defmodule D2 do
  def parse(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)
  end

  def count_safe(ls) do
    ls
    |> Enum.map(&check_rules/1)
    |> Enum.count(fn s -> s != :unsafe end)
  end

  def count_safe_relaxed(ls) do
    ls
    |> Enum.map(&check_rules_skip_1/1)
    |> Enum.count(&Function.identity/1)
  end

  def check_rules_skip_1(l) do
    ls =
      for i <- 0..(length(l) - 1) do
        List.delete_at(l, i)
      end

    ls
    |> Enum.map(&check_rules/1)
    |> Enum.any?(fn x -> x != :unsafe end)
  end

  def check_rules(l) do
    l
    |> Enum.zip(tl(l))
    |> Enum.reduce(:start, &check_rule/2)
  end

  def check_rule(pair, :start) do
    check_pair(pair)
  end

  def check_rule(_, :unsafe), do: :unsafe

  def check_rule(pair, s) do
    if check_pair(pair) == s do
      s
    else
      :unsafe
    end
  end

  def check_pair(t) do
    cond do
      inc(t) -> :inc
      dec(t) -> :dec
      :else -> :unsafe
    end
  end

  def inc({fst, snd}) do
    1 <= snd - fst and snd - fst <= 3
  end

  def dec({fst, snd}) do
    1 <= fst - snd and fst - snd <= 3
  end
end
