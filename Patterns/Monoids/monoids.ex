defmodule PairMonoid do
  def identity, do: {0, 1}

  def combine({a1, b1}, {a2, b2}) do
    {a1 + a2, b1 * b2}
  end
end

val = PairMonoid.combine({3, 2}, {5, 4})
IO.inspect(val)

val = PairMonoid.combine({3, 2}, PairMonoid.identity())
IO.inspect(val)

val = PairMonoid.combine(PairMonoid.combine({1, 2}, {3, 4}), {5, 6})
IO.inspect(val)

val = PairMonoid.combine({1, 2}, PairMonoid.combine({3, 4}, {5, 6}))
IO.inspect(val)
