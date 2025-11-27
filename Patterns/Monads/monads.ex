defmodule Maybe do
  def unit(value), do: {:ok, value}
  def bind({:ok, value}, func), do: func.(value)
  def bind({:error, _} = error, _func), do: error
end

defmodule SafeMath do
  def divide(a, b) when b != 0, do: {:ok, a / b}

  def divide(_, 0),
    do: {:error, :division_by_zero_not_work_or_create_black_hole_so_we_definitely_shouldnt_try}
end

val =
  Maybe.unit(10)
  |> Maybe.bind(fn x -> SafeMath.divide(x, 2) end)
  |> Maybe.bind(fn x -> SafeMath.divide(x, 5) end)

IO.inspect(val)

val =
  Maybe.unit(5)
  |> Maybe.bind(fn x -> SafeMath.divide(x, 5) end)
  |> Maybe.bind(fn x -> SafeMath.divide(x, 0) end)

IO.inspect(val)
