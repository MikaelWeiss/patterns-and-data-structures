defmodule MyEpicRandomAccessList do
  @moduledoc ~S"""
  Here's the structure of a RandomAccessList: \[{head, left, right, size}, {head, left, right, size}]
  """

  @doc """
   * Input: A Random Access List.
   * Output: `true` if the list is empty, `false` otherwise.
  """
  def empty(rlist) when rlsit == [], do: true
  def empty(_rlist), do: false

  @doc """
   * Input: An element and a Random Access List.
   * Output: A new Random Access List with the element added to the front.
  """
  def cons(element, rlist) when rlist == [] do
    [%{head: element, right: nil, left: nil, size: 1}]
  end

  def cons(element, [first]) do
    [%{head: element, left: nil, right: nil, size: 1} | first]
  end

  def cons(element, [first, second | tail]) when first.size == second.size do
    [%{head: element, left: first, right: second, size: first.size + second.size + 1} | tail]
  end

  def cons(element, rlist) do
    [%{head: element, left: nil, right: nil, size: 1} | rlist]
  end

  @doc """
   * Input: A Random Access List.
   * Output: The first element.
  """
  def head([]), do: nil

  def head([head | tail]), do: head.head

  @doc """
   * Input: A Random Access List.
   * Output: The last element.
  """
  def tail([]), do: nil

  def tail(rlist) do
    List.last(rlist)
    |> get_last_element_in_binary_tree
  end

  defp get_last_element_in_binary_tree(tree) when tree.size == 1, do: tree.head
  defp get_last_element_in_binary_tree(tree), do: get_last_element_in_binary_tree(tree.right)

  @doc """
   * Input: A Random Access List and an index.
   * Output: The element at the specified index.
   * Edge Case: Handle out-of-bounds indices properly.
  """
  def lookup([], _index), do: nil

  def lookup([head | tail], index) when head.size <= index and tail != [] do
    lookup(tail, index - head.size)
  end

  def lookup([head | _tail], index) when index == 0, do: head.element

  def lookup([head | _tail], index) when (head.size - 1) / 2 < index do
    lookup([head.left], index - 1 - (head.size - 1) / 2)
  end

  def lookup([head | _tail], index) when index > head.size, do: nil

  def lookup([head | _tail], index) do
    lookup([head.right], index - 1 - (head.size - 1) / 2)
  end

  @doc """
   * Input: A Random Access List, an index, and a new value.
   * Output: A new Random Access List with the specified element updated.
  """
  def update([], _index, _new_value), do: nil

  def update([head | tail], index, new_value) when head.size <= index and tail != [] do
    update(tail, index - head.size, new_value)
  end

  def update([head | _tail], index, new_value) when index == 0 do
    %{head: new_value, left: get_in(head.left), right: get_in(head.right), size: head.size}
  end

  def update([head | _tail], index, new_value) when (head.size - 1) / 2 < index do
    update([head.left], index - 1 - (head.size - 1) / 2, new_value)
  end

  def update([head | _tail], index, new_value) when index > head.size, do: nil

  def update([head | _tail], index, new_value) do
    update([head.right], index - 1 - (head.size - 1) / 2, new_value)
  end

  @doc """
   * Input: A Random Access List.
   * Output: A list containing all elements in order.
  """
  def to_list([]), do: []

  def to_list([head | tail]) do
    [tree_to_list(head) | to_list(tail)]
  end

  defp tree_to_list(nil), do: []

  defp tree_to_list(tree) do
    [tree.head | tree_to_list(get_in(tree.left) || []) ++ tree_to_list(get_in(tree.right) || [])]
  end

  @doc """
   * Input: A standard list.
   * Output: A Random Access List containing the same elements in order.
  """
  def from_list([]), do: []
  def from_list(list), do: to_r_list(list, [])

  defp to_r_list([], rlist), do: rlist
  defp to_r_list([head | tail], rlist), do: to_r_list(tail, cons(head, rlist))
end
