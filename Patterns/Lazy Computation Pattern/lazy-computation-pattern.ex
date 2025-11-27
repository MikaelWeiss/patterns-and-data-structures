import Bitwise

defmodule LazyLazyComputations do
  def get_next_computation(last) do
    next = last <<< 1
    IO.puts(next)
    next
  end
end

alias LazyLazyComputations, as: Lazy

Lazy.get_next_computation(1)
|> Lazy.get_next_computation()
|> Lazy.get_next_computation()
|> Lazy.get_next_computation()
|> Lazy.get_next_computation()
|> Lazy.get_next_computation()
|> Lazy.get_next_computation()
|> Lazy.get_next_computation()
