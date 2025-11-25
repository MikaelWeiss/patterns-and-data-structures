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
  def from_list([h | t]), do: merge(%{0, h, nil, nil}, from_list(t))
end
