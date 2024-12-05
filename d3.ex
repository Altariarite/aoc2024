defmodule D3 do
  for num1_len <- 1..3, num2_len <- 1..3 do
    def mul(
          <<
            "mul",
            "(",
            num1::binary-size(unquote(num1_len)),
            ",",
            num2::binary-size(unquote(num2_len)),
            ")"
          >> <> rest
        ),
        do: {{String.to_integer(num1), String.to_integer(num2)}, rest}
  end

  def mul(<<"do()">> <> rest), do: {:do, rest}

  def mul(<<"don't()">> <> rest), do: {:dont, rest}

  def mul(<<_::binary-size(1)>> <> rest), do: {:invalid, rest}

  def mul(s, is_enabled) do
    {res, rest} = mul(s)

    case res do
      :do ->
        {:do, rest, true}

      :dont ->
        {:dont, rest, false}

      :invalid ->
        {:invalid, rest, is_enabled}

      _ ->
        if is_enabled do
          {res, rest, true}
        else
          {:invalid, rest, false}
        end
    end
  end

  def parse_2("", acc, _), do: acc

  def parse_2(s, acc, enabled?) do
    {res, rest, is_enabled} = mul(s, enabled?)

    if res in [:invalid, :do, :dont] do
      parse_2(rest, acc, is_enabled)
    else
      parse_2(rest, [res | acc], is_enabled)
    end
  end

  def part2(s) do
    parse_2(s, [], true)
    |> Enum.map(fn {fst, snd} -> fst * snd end)
    |> Enum.sum()
  end

  def part1(s) do
    parse(s, [])
    |> Enum.map(fn {fst, snd} -> fst * snd end)
    |> Enum.sum()
  end

  def parse("", acc), do: acc

  def parse(s, acc) do
    {res, rest} = mul(s)

    if res == :invalid do
      parse(rest, acc)
    else
      parse(rest, [res | acc])
    end
  end
end
