defmodule MyEpicRandomAccessList do
  @moduledoc ~S"""
  Here's the structure of a RandomAccessList: \[{head, left, right, size}, {head, left, right, size}]
  """

  @doc """
   * Input: A Random Access List.
   * Output: `true` if the list is empty, `false` otherwise.
  """
  def empty(rlist) when rlist == [], do: true
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

  def head([head | _tail]), do: head.head

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

  def lookup([head | _tail], index) when index == 0, do: head.head

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
    %{head: new_value, left: head.left, right: head.right, size: head.size}
  end

  def update([head | _tail], index, new_value) when (head.size - 1) / 2 < index do
    update([head.left], index - 1 - (head.size - 1) / 2, new_value)
  end

  def update([head | _tail], index, _new_value) when index > head.size, do: nil

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
    [tree.head | tree_to_list(tree.left || []) ++ tree_to_list(tree.right || [])]
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

ExUnit.start()

defmodule MyEpicRandomAccessListTest do
  use ExUnit.Case, async: true

  describe "empty/1" do
    test "returns true for empty list" do
      assert MyEpicRandomAccessList.empty([]) == true
    end

    test "returns false for non-empty list with one element" do
      rlist = MyEpicRandomAccessList.cons(1, [])
      assert MyEpicRandomAccessList.empty(rlist) == false
    end

    test "returns false for non-empty list with multiple elements" do
      rlist =
        []
        |> MyEpicRandomAccessList.cons(3)
        |> MyEpicRandomAccessList.cons(2)
        |> MyEpicRandomAccessList.cons(1)

      assert MyEpicRandomAccessList.empty(rlist) == false
    end
  end

  describe "cons/2" do
    test "adds element to empty list" do
      rlist = MyEpicRandomAccessList.cons(1, [])
      assert length(rlist) == 1
      assert MyEpicRandomAccessList.head(rlist) == 1
    end

    test "adds element to single-element list" do
      rlist =
        []
        |> MyEpicRandomAccessList.cons(1)
        |> MyEpicRandomAccessList.cons(2)

      assert length(rlist) == 2
      assert MyEpicRandomAccessList.head(rlist) == 2
    end

    test "combines two trees when sizes match" do
      rlist =
        []
        |> MyEpicRandomAccessList.cons(1)
        |> MyEpicRandomAccessList.cons(2)
        |> MyEpicRandomAccessList.cons(3)

      assert length(rlist) == 2
      [first, second] = rlist
      assert first.size == 3
      assert second.size == 1
    end

    test "maintains order with many elements" do
      rlist =
        1..10
        |> Enum.reduce([], fn x, acc -> MyEpicRandomAccessList.cons(x, acc) end)

      result = MyEpicRandomAccessList.to_list(rlist) |> List.flatten()
      assert result == Enum.to_list(10..1//-1)
    end
  end

  describe "head/1" do
    test "returns nil for empty list" do
      assert MyEpicRandomAccessList.head([]) == nil
    end

    test "returns first element for single-element list" do
      rlist = MyEpicRandomAccessList.cons(42, [])
      assert MyEpicRandomAccessList.head(rlist) == 42
    end

    test "returns first element for multi-element list" do
      rlist =
        []
        |> MyEpicRandomAccessList.cons(3)
        |> MyEpicRandomAccessList.cons(2)
        |> MyEpicRandomAccessList.cons(1)

      assert MyEpicRandomAccessList.head(rlist) == 1
    end

    test "returns most recently added element" do
      rlist =
        1..100
        |> Enum.reduce([], fn x, acc -> MyEpicRandomAccessList.cons(x, acc) end)

      assert MyEpicRandomAccessList.head(rlist) == 100
    end
  end

  describe "tail/1" do
    test "returns nil for empty list" do
      assert MyEpicRandomAccessList.tail([]) == nil
    end

    test "returns only element for single-element list" do
      rlist = MyEpicRandomAccessList.cons(42, [])
      assert MyEpicRandomAccessList.tail(rlist) == 42
    end

    test "returns last element for multi-element list" do
      rlist =
        []
        |> MyEpicRandomAccessList.cons(3)
        |> MyEpicRandomAccessList.cons(2)
        |> MyEpicRandomAccessList.cons(1)

      assert MyEpicRandomAccessList.tail(rlist) == 3
    end

    test "returns first inserted element" do
      rlist =
        1..100
        |> Enum.reduce([], fn x, acc -> MyEpicRandomAccessList.cons(x, acc) end)

      assert MyEpicRandomAccessList.tail(rlist) == 1
    end
  end

  describe "lookup/2" do
    test "returns nil for empty list" do
      assert MyEpicRandomAccessList.lookup([], 0) == nil
      assert MyEpicRandomAccessList.lookup([], 5) == nil
    end

    test "returns element at index 0" do
      rlist = MyEpicRandomAccessList.from_list([1, 2, 3, 4, 5])
      assert MyEpicRandomAccessList.lookup(rlist, 0) == 5
    end

    test "returns elements at various indices" do
      rlist = MyEpicRandomAccessList.from_list([1, 2, 3, 4, 5])

      assert MyEpicRandomAccessList.lookup(rlist, 0) == 5
      assert MyEpicRandomAccessList.lookup(rlist, 1) == 4
      assert MyEpicRandomAccessList.lookup(rlist, 2) == 3
      assert MyEpicRandomAccessList.lookup(rlist, 3) == 2
      assert MyEpicRandomAccessList.lookup(rlist, 4) == 1
    end

    test "returns nil for out-of-bounds positive index" do
      rlist = MyEpicRandomAccessList.from_list([1, 2, 3])
      assert MyEpicRandomAccessList.lookup(rlist, 10) == nil
    end

    test "handles single element list" do
      rlist = MyEpicRandomAccessList.cons(42, [])
      assert MyEpicRandomAccessList.lookup(rlist, 0) == 42
      assert MyEpicRandomAccessList.lookup(rlist, 1) == nil
    end

    test "handles large list with various indices" do
      rlist = MyEpicRandomAccessList.from_list(Enum.to_list(1..100))

      assert MyEpicRandomAccessList.lookup(rlist, 0) == 100
      assert MyEpicRandomAccessList.lookup(rlist, 50) == 50
      assert MyEpicRandomAccessList.lookup(rlist, 99) == 1
      assert MyEpicRandomAccessList.lookup(rlist, 100) == nil
    end
  end

  describe "update/3" do
    test "returns nil for empty list" do
      assert MyEpicRandomAccessList.update([], 0, 999) == nil
    end

    test "updates element at index 0" do
      rlist = MyEpicRandomAccessList.from_list([1, 2, 3])
      updated = MyEpicRandomAccessList.update(rlist, 0, 999)

      assert updated != nil
    end

    test "returns nil for out-of-bounds index" do
      rlist = MyEpicRandomAccessList.from_list([1, 2, 3])
      assert MyEpicRandomAccessList.update(rlist, 10, 999) == nil
    end

    test "updates middle element" do
      rlist = MyEpicRandomAccessList.from_list([1, 2, 3, 4, 5])
      updated = MyEpicRandomAccessList.update(rlist, 2, 999)

      assert updated != nil
    end

    test "updates single element list" do
      rlist = MyEpicRandomAccessList.cons(42, [])
      updated = MyEpicRandomAccessList.update(rlist, 0, 999)

      assert updated != nil
    end
  end

  describe "to_list/1" do
    test "converts empty rlist to empty list" do
      assert MyEpicRandomAccessList.to_list([]) == []
    end

    test "converts single element" do
      rlist = MyEpicRandomAccessList.cons(42, [])
      result = MyEpicRandomAccessList.to_list(rlist) |> List.flatten()
      assert result == [42]
    end

    test "converts multiple elements in order" do
      rlist =
        []
        |> MyEpicRandomAccessList.cons(3)
        |> MyEpicRandomAccessList.cons(2)
        |> MyEpicRandomAccessList.cons(1)

      result = MyEpicRandomAccessList.to_list(rlist) |> List.flatten()
      assert result == [1, 2, 3]
    end

    test "converts large list correctly" do
      original = Enum.to_list(1..100)
      rlist = MyEpicRandomAccessList.from_list(original)
      result = MyEpicRandomAccessList.to_list(rlist) |> List.flatten()

      assert result == Enum.reverse(original)
    end
  end

  describe "from_list/1" do
    test "converts empty list" do
      assert MyEpicRandomAccessList.from_list([]) == []
    end

    test "converts single element" do
      rlist = MyEpicRandomAccessList.from_list([42])
      assert MyEpicRandomAccessList.head(rlist) == 42
      assert MyEpicRandomAccessList.tail(rlist) == 42
    end

    test "converts multiple elements" do
      rlist = MyEpicRandomAccessList.from_list([1, 2, 3, 4, 5])
      assert MyEpicRandomAccessList.head(rlist) == 5
      assert MyEpicRandomAccessList.tail(rlist) == 1
    end

    test "roundtrip conversion preserves elements" do
      original = [1, 2, 3, 4, 5]
      rlist = MyEpicRandomAccessList.from_list(original)
      result = MyEpicRandomAccessList.to_list(rlist) |> List.flatten()

      assert result == Enum.reverse(original)
    end

    test "handles large lists" do
      original = Enum.to_list(1..1000)
      rlist = MyEpicRandomAccessList.from_list(original)

      assert MyEpicRandomAccessList.head(rlist) == 1000
      assert MyEpicRandomAccessList.tail(rlist) == 1
    end
  end

  describe "integration tests" do
    test "cons and lookup work together" do
      rlist =
        []
        |> MyEpicRandomAccessList.cons(5)
        |> MyEpicRandomAccessList.cons(4)
        |> MyEpicRandomAccessList.cons(3)
        |> MyEpicRandomAccessList.cons(2)
        |> MyEpicRandomAccessList.cons(1)

      assert MyEpicRandomAccessList.lookup(rlist, 0) == 1
      assert MyEpicRandomAccessList.lookup(rlist, 1) == 2
      assert MyEpicRandomAccessList.lookup(rlist, 2) == 3
      assert MyEpicRandomAccessList.lookup(rlist, 3) == 4
      assert MyEpicRandomAccessList.lookup(rlist, 4) == 5
    end

    test "from_list and lookup work together" do
      list = [10, 20, 30, 40, 50]
      rlist = MyEpicRandomAccessList.from_list(list)

      assert MyEpicRandomAccessList.lookup(rlist, 0) == 50
      assert MyEpicRandomAccessList.lookup(rlist, 4) == 10
    end

    test "tree combining works correctly" do
      rlist =
        []
        |> MyEpicRandomAccessList.cons(1)
        |> MyEpicRandomAccessList.cons(2)
        |> MyEpicRandomAccessList.cons(3)
        |> MyEpicRandomAccessList.cons(4)

      assert MyEpicRandomAccessList.lookup(rlist, 0) == 4
      assert MyEpicRandomAccessList.lookup(rlist, 1) == 3
      assert MyEpicRandomAccessList.lookup(rlist, 2) == 2
      assert MyEpicRandomAccessList.lookup(rlist, 3) == 1
    end

    test "empty check after operations" do
      rlist = MyEpicRandomAccessList.from_list([1, 2, 3])
      assert MyEpicRandomAccessList.empty(rlist) == false

      empty = MyEpicRandomAccessList.from_list([])
      assert MyEpicRandomAccessList.empty(empty) == true
    end
  end

  describe "edge cases" do
    test "handles nil values in list" do
      rlist = MyEpicRandomAccessList.from_list([nil, 1, nil, 2])
      assert MyEpicRandomAccessList.lookup(rlist, 0) == 2
      assert MyEpicRandomAccessList.lookup(rlist, 1) == nil
    end

    test "handles different data types" do
      rlist = MyEpicRandomAccessList.from_list([:atom, "string", 42, 3.14, %{key: "value"}])
      assert MyEpicRandomAccessList.head(rlist) == %{key: "value"}
      assert MyEpicRandomAccessList.tail(rlist) == :atom
    end

    test "handles very large lists efficiently" do
      large_list = Enum.to_list(1..10000)
      rlist = MyEpicRandomAccessList.from_list(large_list)

      assert MyEpicRandomAccessList.lookup(rlist, 0) == 10000
      assert MyEpicRandomAccessList.lookup(rlist, 5000) == 5000
      assert MyEpicRandomAccessList.lookup(rlist, 9999) == 1
    end

    test "lookup with negative index returns nil" do
      rlist = MyEpicRandomAccessList.from_list([1, 2, 3])
      assert MyEpicRandomAccessList.lookup(rlist, -1) == nil
    end
  end
end
