defmodule D13 do
  use Agent

  defmodule Button do
    defstruct [:x, :y]
  end

  def parse(s) do
    s
    |> String.split("\n\n")
    |> Enum.map(fn s -> String.split(s, "\n") end)
    |> Enum.map(&parse_list/1)
  end

  def parse_button("Button " <> <<name::binary-size(1)>> <> ": " <> tl) do
    {name, tl}
  end

  def parse_xy({name, s}) do
    ["X+" <> x, "Y+" <> y] = s |> String.split(", ")
    %Button{:x => x |> String.to_integer(), :y => y |> String.to_integer()}
  end

  def parse_prize(s) do
    ["Prize: X=" <> x, "Y=" <> y] = s |> String.split(", ")
    {x |> String.to_integer(), y |> String.to_integer()}
  end

  def parse_list([a, b, prize]) do
    prize = parse_prize(prize)

    [
      prize,
      a |> parse_button() |> parse_xy,
      b |> parse_button() |> parse_xy
    ]
  end

  def solve({x, y}, a, b) do
    na = (x * b.y - y * b.x) |> div(b.y * a.x - b.x * a.y)
    nb = (x * a.y - y * a.x) |> div(b.x * a.y - b.y * a.x)

    if x == na * a.x + nb * b.x and
         y == na * a.y + nb * b.y and
         na <= 100 and nb <= 100 do
      {na, nb}
    else
      nil
    end
  end

  def part1(filename) do
    File.read!(filename)
    |> parse()
    |> Enum.map(fn [prize, a, b] -> solve(prize, a, b) end)
    |> Enum.filter(&Function.identity/1)
    |> Enum.reduce(0, fn {a, b}, acc -> 3 * a + b + acc end)
  end

  def solve_p2({x, y}, a, b) do
    {x, y} = {x + 10_000_000_000_000, y + 10_000_000_000_000}
    na = (x * b.y - y * b.x) |> div(b.y * a.x - b.x * a.y)
    nb = (x * a.y - y * a.x) |> div(b.x * a.y - b.y * a.x)

    if x == na * a.x + nb * b.x and
         y == na * a.y + nb * b.y do
      {na, nb}
    else
      nil
    end
  end

  def part2(filename) do
    File.read!(filename)
    |> parse()
    |> Enum.map(fn [prize, a, b] -> solve_p2(prize, a, b) end)
    |> Enum.filter(&Function.identity/1)
    |> Enum.reduce(0, fn {a, b}, acc -> 3 * a + b + acc end)
  end
end
