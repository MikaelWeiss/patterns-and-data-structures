defmodule ResultFunctor do
  def map({:ok, value}, func), do: {:ok, func.(value)}
  def map({:error, reason}, _func), do: {:error, reason}
end

IO.inspect(ResultFunctor.map({:ok, 5}, fn x -> x * 2 end))
IO.inspect(ResultFunctor.map({:error, "failed"}, fn x -> x * 2 end))
