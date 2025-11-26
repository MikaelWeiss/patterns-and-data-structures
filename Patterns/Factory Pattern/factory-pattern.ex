defmodule MikesCircularList do
  @moduledoc ~S"""
  A circular list [{value, next_index}]
  """
  def build_circular_list_of_three() do
    [%{value: 5, next_index: 1}, %{value: 2, next_index: 2}, %{value: 10, next_index: 0}]
  end
end

list = MikesCircularList.build_circular_list_of_three()
IO.inspect(list)
