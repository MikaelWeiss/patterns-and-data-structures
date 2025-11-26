defmodule Chaining do
  defp square(i), do: i * i

  defp add(start, acc), do: start + acc

  defp sqrt(i), do: :math.sqrt(i)

  def chain(i) do
    i
    |> square
    |> add(5)
    |> sqrt
  end
end

IO.puts("#{Chaining.chain(5)}")
