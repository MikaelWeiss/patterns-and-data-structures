defmodule StatelessFunctions do
  def add_primes([]), do: 0
  def add_primes([head | tail]) do
    if is_prime(head) do
      head + add_primes(tail)
    else
      add_primes(tail)
    end
  end

  def is_prime(1), do: false
  def is_prime(2), do: true
  def is_prime(n) when n > 2 and rem(n, 2) == 0, do: false
  def is_prime(n) do
    not Enum.any?(3..trunc(:math.sqrt(n))//2, fn i -> rem(n, i) == 0 end)
  end
end

IO.puts(StatelessFunctions.add_primes(Enum.to_list(1..50)))
