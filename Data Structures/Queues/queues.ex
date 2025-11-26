defmodule MyEpicQueue do
  # Empty
  def empty({[], []}) do
    true
  end

  def empty(_) do
    false
  end

  # Enqueue
  def enqueue({front_list, back_list}, element) do
    {front_list, [element | back_list]}
  end

  # Dequeue
  def dequeue({[], []}) do
    {:error, :empty_queue}
  end

  def dequeue({[], back_list}) do
    [head | tail] = Enum.reverse(back_list)
    {{:ok, head}, {tail, []}}
  end

  def dequeue({[head | tail], back_list}) do
    {{:ok, head}, {tail, back_list}}
  end

  # Head
  def head({[], []}) do
    nil
  end

  def head({[], back_list}) do
    [head | _tail] = Enum.reverse(back_list)
    head
  end

  def head({[head | _tail], _back_list}) do
    head
  end

  # Tail
  def tail({[], []}) do
    nil
  end

  def tail({front_list, []}) do
    List.last(front_list)
  end

  def tail({_front_list, back_list}) do
    List.first(back_list)
  end

  # ToList
  def to_list({front_list, back_list}) do
    front_list ++ Enum.reverse(back_list)
  end

  # FromList
  def from_list(list) do
    {list, []}
  end
end

# NOTES ABOUT THE TESTS
# ~~~~~~~~~~~~~~~~~~~~~
# These tests were written by AI. The rest ^ was me though.
# Let me know if you want anything different.
# I just figured that having more comprehensive tests is good,
# and having AI write the tests makes that more possible with limited time.
# ~~~~~~~~~~~~~~~~~~~~~

# Tests
defmodule MyEpicQueueTest do
  # Create empty queue for testing
  defp empty_queue, do: {[], []}

  def run_tests do
    IO.puts("Running MyEpicQueue tests...")

    test_empty_queue()
    test_enqueue_dequeue()
    test_head_tail()
    test_list_conversions()
    test_fifo_behavior()
    test_sequential_operations()

    IO.puts("All tests passed! ✅")
  end

  defp test_empty_queue do
    IO.puts("  ✓ Testing empty queue operations")

    q = empty_queue()
    assert MyEpicQueue.empty(q) == true

    # Test dequeue on empty queue
    assert MyEpicQueue.dequeue(q) == {:error, :empty_queue}

    # Test head on empty queue
    assert MyEpicQueue.head(q) == nil

    # Test tail on empty queue
    assert MyEpicQueue.tail(q) == nil
  end

  defp test_enqueue_dequeue do
    IO.puts("  ✓ Testing enqueue and dequeue")

    # Start with empty queue
    q = empty_queue()

    # Enqueue elements
    q = MyEpicQueue.enqueue(q, 1)
    q = MyEpicQueue.enqueue(q, 2)
    q = MyEpicQueue.enqueue(q, 3)

    assert MyEpicQueue.empty(q) == false

    # Dequeue elements (FIFO order)
    {{:ok, first}, q} = MyEpicQueue.dequeue(q)
    assert first == 1

    {{:ok, second}, q} = MyEpicQueue.dequeue(q)
    assert second == 2

    {{:ok, third}, q} = MyEpicQueue.dequeue(q)
    assert third == 3

    # Queue should be empty now
    assert MyEpicQueue.empty(q) == true
  end

  defp test_head_tail do
    IO.puts("  ✓ Testing head and tail operations")

    q = empty_queue()

    # Single element
    q = MyEpicQueue.enqueue(q, :only)
    assert MyEpicQueue.head(q) == :only
    assert MyEpicQueue.tail(q) == :only

    # Multiple elements
    q = MyEpicQueue.enqueue(q, :middle)
    q = MyEpicQueue.enqueue(q, :last)

    assert MyEpicQueue.head(q) == :only
    assert MyEpicQueue.tail(q) == :last

    # After dequeue
    {{:ok, _}, q} = MyEpicQueue.dequeue(q)
    assert MyEpicQueue.head(q) == :middle
    assert MyEpicQueue.tail(q) == :last
  end

  defp test_list_conversions do
    IO.puts("  ✓ Testing list conversions")

    # From list to queue
    list = [1, 2, 3, 4, 5]
    q = MyEpicQueue.from_list(list)

    # To list from queue
    converted_back = MyEpicQueue.to_list(q)
    assert converted_back == list

    # Empty list
    empty_q = MyEpicQueue.from_list([])
    assert MyEpicQueue.empty(empty_q) == true
    assert MyEpicQueue.to_list(empty_q) == []
  end

  defp test_fifo_behavior do
    IO.puts("  ✓ Testing FIFO behavior")

    q = empty_queue()

    # Enqueue multiple elements
    elements = [:a, :b, :c, :d]

    q =
      Enum.reduce(elements, q, fn elem, acc_q ->
        MyEpicQueue.enqueue(acc_q, elem)
      end)

    # Dequeue and verify order
    {results, _final_q} =
      for _elem <- elements, reduce: {[], q} do
        {acc, current_q} ->
          {{:ok, value}, new_q} = MyEpicQueue.dequeue(current_q)
          {[value | acc], new_q}
      end

    results = Enum.reverse(results)

    assert results == elements
  end

  defp test_sequential_operations do
    IO.puts("  ✓ Testing sequential operations")

    q = empty_queue()

    # Mix of operations
    q = MyEpicQueue.enqueue(q, "first")
    {{:ok, first}, q} = MyEpicQueue.dequeue(q)
    assert first == "first"

    q = MyEpicQueue.enqueue(q, "second")
    q = MyEpicQueue.enqueue(q, "third")

    {{:ok, second}, q} = MyEpicQueue.dequeue(q)
    assert second == "second"

    assert MyEpicQueue.head(q) == "third"
    assert MyEpicQueue.tail(q) == "third"

    {{:ok, third}, q} = MyEpicQueue.dequeue(q)
    assert third == "third"

    assert MyEpicQueue.empty(q) == true
  end

  defp assert(true), do: :ok
  defp assert(false), do: raise("Assertion failed!")
end

# Run tests
MyEpicQueueTest.run_tests()
