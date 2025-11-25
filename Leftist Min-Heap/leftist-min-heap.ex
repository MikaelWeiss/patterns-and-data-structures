defmodule MyEpicLeftistMinHeap do
  @moduledoc """
  Heap Structure: {rank, value, next_left, next_right}
  """

  @doc """
   * Input: A Leftist Min-Heap.
   * Output: `true` if the heap is empty, `false` otherwise.
  """
  def empty({}), do: true
  def empty(nil), do: true
  def empty(_heap), do: false

  @doc """
   * Input: A Leftist Min-Heap and an element.
   * Output: A new Leftist Min-Heap with the element inserted.
  """
  def insert(heap, element),
    do: merge(heap, %{rank: 0, value: element, next_left: nil, next_right: nil})

  @doc """
   * Input: A Leftist Min-Heap.
   * Output: The minimum element (at the root) without modifying the heap.
  """
  def find_min(nil), do: nil

  def find_min(heap), do: heap.value

  @doc """
   * Input: A Leftist Min-Heap.
   * Output: A new Leftist Min-Heap with the minimum element removed.
  """
  def delete_min(nil), do: nil

  def delete_min(heap), do: merge(heap.next_left, heap.next_right)

  @doc """
   * Input: Two Leftist Min-Heaps.
   * Output: A new Leftist Min-Heap that contains all elements from both input heaps.
  """
  def merge(nil, rheap), do: rheap
  def merge(lheap, nil), do: lheap

  def merge(lheap, rheap) when lheap.value < rheap.value do
    # Min element is in the left heap. Merge right subtree of left heap with right heap
    new_right = merge(lheap.next_right, rheap)
    new_right = %{new_right | rank: new_right.next_right.rank + 1}

    %{lheap | next_right: new_right}
    |> check_rank_and_possibly_swap
  end

  def merge(lheap, rheap) do
    # Min element is in right heap. Merge right subtree of right heap with left heap
    new_right = merge(rheap.next_right, lheap)
    new_right = %{new_right | rank: new_right.next_right.rank + 1}

    %{rheap | next_right: new_right}
    |> check_rank_and_possibly_swap
  end

  # If the left's rank is less than the right, then swap them
  defp check_rank_and_possibly_swap(heap) when heap.next_left.rank < heap.next_right.rank do
    %{heap | next_left: heap.next_right, next_right: heap.next_left}
  end

  defp check_rank_and_possibly_swap(heap), do: heap

  @doc """
   * Input: A Leftist Min-Heap.
   * Output: A list of elements sorted in ascending order.
  """
  def to_list(heap) when heap.next_left == nil and heap.next_right == nil do
    [heap.value]
  end

  def to_list(heap) when heap.next_left == nil do
    [heap.value | to_list(heap.next_right)]
  end

  def to_list(heap) when heap.next_right == nil do
    [heap.value | to_list(heap.next_left)]
  end

  def to_list(heap) do
    left_list = to_list(heap.next_left)
    right_list = to_list(heap.next_right)
    [heap.value | merge_list(left_list, right_list)]
  end

  defp merge_list(left_list, right_list) do
    (left_list ++ right_list)
    |> Enum.sort()
  end

  @doc """
   * Input: A standard list of elements.
   * Output: A Leftist Min-Heap containing all the elements.
  """
  def from_list([h | t]),
    do: merge(%{rank: 0, value: h, next_left: nil, next_right: nil}, from_list(t))
end

ExUnit.start()

defmodule MyEpicLeftistMinHeapTest do
  use ExUnit.Case
  alias MyEpicLeftistMinHeap, as: Heap

  describe "empty/1" do
    test "returns true for empty tuple" do
      assert Heap.empty({})
    end

    test "returns true for nil" do
      assert Heap.empty(nil)
    end

    test "returns false for non-empty heap" do
      heap = %{rank: 0, value: 5, next_left: nil, next_right: nil}
      refute Heap.empty(heap)
    end
  end

  describe "insert/2" do
    test "inserts into empty heap" do
      heap = Heap.insert(nil, 5)
      assert Heap.find_min(heap) == 5
    end

    test "inserts smaller element becomes new min" do
      heap =
        nil
        |> Heap.insert(10)
        |> Heap.insert(5)

      assert Heap.find_min(heap) == 5
    end

    test "inserts larger element maintains min" do
      heap =
        nil
        |> Heap.insert(5)
        |> Heap.insert(10)

      assert Heap.find_min(heap) == 5
    end

    test "inserts multiple elements in random order" do
      heap =
        nil
        |> Heap.insert(15)
        |> Heap.insert(3)
        |> Heap.insert(20)
        |> Heap.insert(1)
        |> Heap.insert(8)

      assert Heap.find_min(heap) == 1
    end

    test "inserts duplicate elements" do
      heap =
        nil
        |> Heap.insert(5)
        |> Heap.insert(5)
        |> Heap.insert(5)

      assert Heap.find_min(heap) == 5
    end
  end

  describe "find_min/1" do
    test "returns nil for nil heap" do
      assert Heap.find_min(nil) == nil
    end

    test "returns single element" do
      heap = Heap.insert(nil, 42)
      assert Heap.find_min(heap) == 42
    end

    test "returns minimum after multiple inserts" do
      heap =
        nil
        |> Heap.insert(100)
        |> Heap.insert(50)
        |> Heap.insert(25)
        |> Heap.insert(75)

      assert Heap.find_min(heap) == 25
    end

    test "find_min does not modify heap" do
      heap =
        nil
        |> Heap.insert(10)
        |> Heap.insert(5)

      assert Heap.find_min(heap) == 5
      assert Heap.find_min(heap) == 5
    end
  end

  describe "delete_min/1" do
    test "returns nil for nil heap" do
      assert Heap.delete_min(nil) == nil
    end

    test "deletes only element returns empty heap" do
      heap = Heap.insert(nil, 5)
      result = Heap.delete_min(heap)
      assert Heap.empty(result) || result == nil
    end

    test "deletes min and exposes next minimum" do
      heap =
        nil
        |> Heap.insert(5)
        |> Heap.insert(10)
        |> Heap.insert(3)

      heap = Heap.delete_min(heap)
      assert Heap.find_min(heap) == 5

      heap = Heap.delete_min(heap)
      assert Heap.find_min(heap) == 10
    end

    test "deletes all elements one by one" do
      heap =
        nil
        |> Heap.insert(30)
        |> Heap.insert(10)
        |> Heap.insert(20)

      heap = Heap.delete_min(heap)
      assert Heap.find_min(heap) == 20

      heap = Heap.delete_min(heap)
      assert Heap.find_min(heap) == 30

      heap = Heap.delete_min(heap)
      assert heap == nil || Heap.empty(heap)
    end

    test "handles duplicate minimums" do
      heap =
        nil
        |> Heap.insert(5)
        |> Heap.insert(5)
        |> Heap.insert(10)

      heap = Heap.delete_min(heap)
      assert Heap.find_min(heap) == 5

      heap = Heap.delete_min(heap)
      assert Heap.find_min(heap) == 10
    end
  end

  describe "merge/2" do
    test "merges nil with heap returns heap" do
      heap = Heap.insert(nil, 5)
      result = Heap.merge(nil, heap)
      assert Heap.find_min(result) == 5
    end

    test "merges heap with nil returns heap" do
      heap = Heap.insert(nil, 5)
      result = Heap.merge(heap, nil)
      assert Heap.find_min(result) == 5
    end

    test "merges two single-element heaps" do
      heap1 = Heap.insert(nil, 5)
      heap2 = Heap.insert(nil, 10)
      result = Heap.merge(heap1, heap2)

      assert Heap.find_min(result) == 5
    end

    test "merges maintains min from first heap" do
      heap1 = nil |> Heap.insert(3) |> Heap.insert(7)
      heap2 = nil |> Heap.insert(5) |> Heap.insert(9)
      result = Heap.merge(heap1, heap2)

      assert Heap.find_min(result) == 3
    end

    test "merges maintains min from second heap" do
      heap1 = nil |> Heap.insert(8) |> Heap.insert(12)
      heap2 = nil |> Heap.insert(2) |> Heap.insert(6)
      result = Heap.merge(heap1, heap2)

      assert Heap.find_min(result) == 2
    end

    test "merges preserves all elements" do
      heap1 = nil |> Heap.insert(1) |> Heap.insert(3) |> Heap.insert(5)
      heap2 = nil |> Heap.insert(2) |> Heap.insert(4) |> Heap.insert(6)
      result = Heap.merge(heap1, heap2)

      list = Heap.to_list(result)
      assert length(list) == 6
      assert Enum.sort(list) == [1, 2, 3, 4, 5, 6]
    end

    test "merge is associative" do
      heap1 = Heap.insert(nil, 1)
      heap2 = Heap.insert(nil, 2)
      heap3 = Heap.insert(nil, 3)

      result1 = Heap.merge(Heap.merge(heap1, heap2), heap3)
      result2 = Heap.merge(heap1, Heap.merge(heap2, heap3))

      assert Heap.to_list(result1) |> Enum.sort() ==
               Heap.to_list(result2) |> Enum.sort()
    end
  end

  describe "to_list/1" do
    test "converts single element heap" do
      heap = Heap.insert(nil, 42)
      assert Heap.to_list(heap) == [42]
    end

    test "converts heap to sorted list" do
      heap =
        nil
        |> Heap.insert(5)
        |> Heap.insert(2)
        |> Heap.insert(8)
        |> Heap.insert(1)
        |> Heap.insert(9)

      list = Heap.to_list(heap)
      assert Enum.sort(list) == [1, 2, 5, 8, 9]
    end

    test "handles duplicates in list" do
      heap =
        nil
        |> Heap.insert(5)
        |> Heap.insert(3)
        |> Heap.insert(5)
        |> Heap.insert(3)

      list = Heap.to_list(heap)
      assert Enum.sort(list) == [3, 3, 5, 5]
    end

    test "list contains all inserted elements" do
      elements = [15, 3, 20, 1, 8, 12, 6]
      heap = Enum.reduce(elements, nil, &Heap.insert(&2, &1))
      list = Heap.to_list(heap)

      assert length(list) == length(elements)
      assert Enum.sort(list) == Enum.sort(elements)
    end
  end

  describe "from_list/1" do
    test "creates heap from single element list" do
      heap = Heap.from_list([42])
      assert Heap.find_min(heap) == 42
    end

    test "creates heap from multiple elements" do
      heap = Heap.from_list([5, 2, 8, 1, 9])
      assert Heap.find_min(heap) == 1
    end

    test "creates heap preserving all elements" do
      list = [15, 3, 20, 1, 8, 12, 6]
      heap = Heap.from_list(list)
      result_list = Heap.to_list(heap)

      assert Enum.sort(result_list) == Enum.sort(list)
    end

    test "from_list handles duplicates" do
      heap = Heap.from_list([5, 5, 5, 3, 3])
      list = Heap.to_list(heap)
      assert Enum.sort(list) == [3, 3, 5, 5, 5]
    end

    test "round trip: list -> heap -> list" do
      original = [7, 2, 9, 4, 1, 6, 3, 8, 5]
      heap = Heap.from_list(original)
      result = Heap.to_list(heap)

      assert Enum.sort(result) == Enum.sort(original)
    end
  end

  describe "heap property" do
    test "maintains leftist property through insertions" do
      heap =
        nil
        |> Heap.insert(10)
        |> Heap.insert(5)
        |> Heap.insert(15)
        |> Heap.insert(3)
        |> Heap.insert(7)
        |> Heap.insert(12)
        |> Heap.insert(20)

      values = extract_all_min(heap, [])
      assert values == Enum.sort(values)
    end

    test "maintains heap property after merges" do
      heap1 = Heap.from_list([1, 5, 9, 13])
      heap2 = Heap.from_list([2, 6, 10, 14])
      merged = Heap.merge(heap1, heap2)

      values = extract_all_min(merged, [])
      assert values == Enum.sort(values)
    end

    test "stress test: many operations maintain heap property" do
      heap = Heap.from_list(Enum.to_list(1..100))

      heap = Enum.reduce(1..10, heap, fn _, h -> Heap.delete_min(h) end)

      heap = Enum.reduce(1..10, heap, fn i, h -> Heap.insert(h, i) end)

      values = extract_all_min(heap, [])
      assert values == Enum.sort(values)
    end
  end

  describe "edge cases" do
    test "works with negative numbers" do
      heap =
        nil
        |> Heap.insert(-5)
        |> Heap.insert(-10)
        |> Heap.insert(0)
        |> Heap.insert(5)

      assert Heap.find_min(heap) == -10
    end

    test "works with floats" do
      heap =
        nil
        |> Heap.insert(3.14)
        |> Heap.insert(2.71)
        |> Heap.insert(1.41)

      assert Heap.find_min(heap) == 1.41
    end

    test "works with large dataset" do
      elements = Enum.shuffle(1..1000)
      heap = Enum.reduce(elements, nil, &Heap.insert(&2, &1))

      assert Heap.find_min(heap) == 1

      mins = extract_n_min(heap, 10, [])
      assert mins == Enum.to_list(1..10)
    end
  end

  defp extract_all_min(nil, acc), do: Enum.reverse(acc)

  defp extract_all_min(heap, acc) do
    min = Heap.find_min(heap)
    new_heap = Heap.delete_min(heap)
    extract_all_min(new_heap, [min | acc])
  end

  defp extract_n_min(_heap, 0, acc), do: Enum.reverse(acc)
  defp extract_n_min(nil, _n, acc), do: Enum.reverse(acc)

  defp extract_n_min(heap, n, acc) do
    min = Heap.find_min(heap)
    new_heap = Heap.delete_min(heap)
    extract_n_min(new_heap, n - 1, [min | acc])
  end
end
