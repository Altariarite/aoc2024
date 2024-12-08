defmodule D7 do
  def parse(s) do
    for line <- s |> String.split("\n") do
      [sum, ls] = line |> String.split(":")
      nums = ls |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
      {String.to_integer(sum), nums}
    end
  end

  # [10] 19 -> [190, 29]
  # [81] 40 -> [81*40, 121]
  # [81*40, 121] 27 -> [...4 elements]
  def add_or_mul(nums, next) do
    nums
    |> Stream.flat_map(fn n -> [n * next, n + next] end)
  end

  def permutations([hd | tl], func) do
    permutations(tl, [hd], func)
  end

  def permutations([], acc, _), do: acc

  def permutations([hd | tl], acc, func) do
    permutations(tl, func.(acc, hd), func)
  end

  def calibarate({sum, nums}, func) do
    if sum in permutations(nums, func) do
      sum
    else
      0
    end
  end

  def part1(filename) do
    File.read!(filename)
    |> D7.parse()
    |> Enum.map(fn l -> calibarate(l, &add_or_mul/2) end)
    |> IO.inspect()
    |> Enum.sum()
  end

  def concat(n1, n2) do
    "#{n1}#{n2}" |> String.to_integer()
  end

  # [10] 19 -> [190, 29, 1019]
  # [81*40, 121] 27 -> [81*40+27, 81*40*27, 81*40 || 27]
  def add_mul_or_concat(nums, next) do
    nums
    |> Stream.flat_map(fn n -> [n * next, n + next, concat(n, next)] end)
  end

  def part2(filename) do
    File.read!(filename)
    |> D7.parse()
    |> Enum.map(fn l -> calibarate(l, &add_mul_or_concat/2) end)
    |> IO.inspect()
    |> Enum.sum()
  end
end
