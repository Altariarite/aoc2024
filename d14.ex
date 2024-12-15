defmodule D14 do
  @real {101, 103}
  @test {11, 7}

  def parse_robot(s) do
    ["p=" <> pos, "v=" <> vel] = s |> String.split(" ")

    {pos |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple(),
     vel |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()}
  end

  def parse(filename) do
    File.read!(filename)
    |> String.split("\n")
    |> Enum.map(&parse_robot/1)
  end

  # robots can wrap
  def wrap(i, w) do
    cond do
      i >= w ->
        rem(i, w)

      i < 0 ->
        rem(i, w) + w

      :else ->
        i
    end
  end

  def next_pos({{x, y}, {vx, vy}}, {w, h}) do
    {wrap(x + vx, w), wrap(y + vy, h)}
  end

  def next_poss({pos, vel}, bound, i) do
    for _ <- 1..i, reduce: pos do
      pos -> next_pos({pos, vel}, bound)
    end
  end

  def quadrant({x, y}, {w, h}) do
    {midw, midh} = {div(w, 2), div(h, 2)}

    cond do
      x < midw and y < midh -> :q1
      x > midw and y < midh -> :q2
      x < midw and y > midh -> :q3
      x > midw and y > midh -> :q4
      :else -> :discard
    end
  end

  def part1(robots, time) do
    bound = @real

    robots
    |> Enum.map(fn r -> next_poss(r, bound, time) end)
    |> Enum.map(fn pos -> quadrant(pos, bound) end)
    |> Enum.filter(fn t -> t != :discard end)
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.product()
  end
end
