defmodule D2 do
  def parse(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
  end

  def count_safe(ls) do
    ls
    |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)
    |> Enum.map(fn l -> {l, check_rules(l)} end)

    # |> Enum.count(fn s -> s != :unsafe end)
  end

  def check_rules(l) do
    l
    |> Enum.zip(tl(l))
    |> Enum.reduce({:start, :unmodified}, &check_rule/2)
  end

  # :unmodified - carry number - :modified
  def check_rule({fst, snd}, {:start, :unmodified}) do
    cond do
      1 <= snd - fst and snd - fst <= 3 -> {:inc, :unmodified}
      1 <= fst - snd and fst - snd <= 3 -> {:dec, :unmodified}
      :else -> {:start, fst}
    end
  end

  def check_rule({fst, snd}, {s, :unmodified}) do
    cond do
      1 <= snd - fst and snd - fst <= 3 and s == :inc -> {:inc, :unmodified}
      1 <= fst - snd and fst - snd <= 3 and s == :dec -> {:dec, :unmodified}
      :else -> {s, fst}
    end
  end

  def check_rule({fst, snd}, {s, :modified}) do
    cond do
      1 <= snd - fst and snd - fst <= 3 and s == :inc -> {:inc, :modified}
      1 <= fst - snd and fst - snd <= 3 and s == :dec -> {:dec, :modified}
      :else -> :unsafe
    end
  end

  def check_rule({fst, snd}, {:start, prev}) do
    cond do
      1 <= snd - fst and snd - fst <= 3 -> {:inc, :modified}
      1 <= fst - snd and fst - snd <= 3 -> {:dec, :modified}
      1 <= snd - prev and snd - prev <= 3 -> {:inc, :modified}
      1 <= prev - snd and prev - snd <= 3 -> {:dec, :modified}
      :else -> :unsafe
    end
  end

  def check_rule({_, snd}, {s, prev}) do
    cond do
      1 <= snd - prev and snd - prev <= 3 and s == :inc -> {:inc, :modified}
      1 <= prev - snd and prev - snd <= 3 and s == :dec -> {:dec, :modified}
      :else -> :unsafe
    end
  end

  def check_rule(_, :unsafe), do: :unsafe
end
