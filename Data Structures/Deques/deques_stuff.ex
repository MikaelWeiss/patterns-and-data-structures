defmodule MyEpicDeque do
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

  def enqueue_front({front_list, back_list}, element) do
    {[element | front_list], back_list}
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

  # Dequeue Back

  def dequeue_back({[], []}) do
    {:error, :empty_queue}
  end

  def dequeue_back({front_list, []}) do
    [head | tail] = Enum.reverse(front_list)
    {{:ok, head}, {[], tail}}
  end

  def dequeue_back({front_list, [head | tail]}) do
    {{:ok, head}, {front_list, tail}}
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

defmodule MyEpicDequeTest do
  @empty_deque {[], []}

  def run_all_tests do
    IO.puts("Running MyEpicDeque tests...")

    test_empty()
    test_enqueue_dequeue()
    test_enqueue_front_dequeue_back()
    test_head_tail()
    test_to_list_from_list()
    test_combined_operations()
    test_edge_cases()

    IO.puts("All tests completed!")
  end

  def test_empty do
    IO.puts("\nTesting empty/1...")

    assert MyEpicDeque.empty(@empty_deque) == true, "Empty deque should return true"
    assert MyEpicDeque.empty({[1, 2], []}) == false, "Non-empty deque should return false"
    assert MyEpicDeque.empty({[], [3, 4]}) == false, "Deque with back elements should return false"

    IO.puts("✓ empty/1 tests passed")
  end

  def test_enqueue_dequeue do
    IO.puts("\nTesting enqueue/2 and dequeue/1...")

    # Enqueue to empty deque
    deque1 = MyEpicDeque.enqueue(@empty_deque, 1)
    assert MyEpicDeque.to_list(deque1) == [1], "Should enqueue element to rear"

    # Multiple enqueues
    deque2 = MyEpicDeque.enqueue(deque1, 2)
    deque3 = MyEpicDeque.enqueue(deque2, 3)
    assert MyEpicDeque.to_list(deque3) == [1, 2, 3], "Should maintain order"

    # Dequeue operations
    {{:ok, elem1}, deque4} = MyEpicDeque.dequeue(deque3)
    assert elem1 == 1, "Should dequeue first element (1)"
    assert MyEpicDeque.to_list(deque4) == [2, 3], "Should maintain remaining elements"

    {{:ok, elem2}, deque5} = MyEpicDeque.dequeue(deque4)
    assert elem2 == 2, "Should dequeue second element (2)"

    {{:ok, elem3}, deque6} = MyEpicDeque.dequeue(deque5)
    assert elem3 == 3, "Should dequeue third element (3)"
    assert MyEpicDeque.empty(deque6) == true, "Deque should be empty after removing all elements"

    # Dequeue from empty deque
    assert MyEpicDeque.dequeue(@empty_deque) == {:error, :empty_queue}, "Should return error for empty deque"

    IO.puts("✓ enqueue/2 and dequeue/1 tests passed")
  end

  def test_enqueue_front_dequeue_back do
    IO.puts("\nTesting enqueue_front/2 and dequeue_back/1...")

    # Enqueue_front to empty deque
    deque1 = MyEpicDeque.enqueue_front(@empty_deque, 1)
    assert MyEpicDeque.to_list(deque1) == [1], "Should enqueue element to front"

    # Multiple enqueue_front operations
    deque2 = MyEpicDeque.enqueue_front(deque1, 2)
    deque3 = MyEpicDeque.enqueue_front(deque2, 3)
    assert MyEpicDeque.to_list(deque3) == [3, 2, 1], "Should reverse order for front enqueues"

    # Dequeue_back operations
    {{:ok, elem1}, deque4} = MyEpicDeque.dequeue_back(deque3)
    assert elem1 == 1, "Should dequeue back element (1)"
    assert MyEpicDeque.to_list(deque4) == [3, 2], "Should maintain remaining elements"

    {{:ok, elem2}, deque5} = MyEpicDeque.dequeue_back(deque4)
    assert elem2 == 2, "Should dequeue back element (2)"

    {{:ok, elem3}, deque6} = MyEpicDeque.dequeue_back(deque5)
    assert elem3 == 3, "Should dequeue back element (3)"
    assert MyEpicDeque.empty(deque6) == true, "Deque should be empty after removing all elements"

    # Dequeue_back from empty deque
    assert MyEpicDeque.dequeue_back(@empty_deque) == {:error, :empty_queue}, "Should return error for empty deque"

    IO.puts("✓ enqueue_front/2 and dequeue_back/1 tests passed")
  end

  def test_head_tail do
    IO.puts("\nTesting head/1 and tail/1...")

    # Empty deque
    assert MyEpicDeque.head(@empty_deque) == nil, "Head of empty deque should be nil"
    assert MyEpicDeque.tail(@empty_deque) == nil, "Tail of empty deque should be nil"

    # Single element
    deque1 = MyEpicDeque.enqueue(@empty_deque, 42)
    assert MyEpicDeque.head(deque1) == 42, "Head should be 42"
    assert MyEpicDeque.tail(deque1) == 42, "Tail should be 42 for single element"

    # Multiple elements
    deque2 = MyEpicDeque.enqueue(deque1, 24)
    assert MyEpicDeque.head(deque2) == 42, "Head should be first element (42)"
    assert MyEpicDeque.tail(deque2) == 24, "Tail should be last element (24)"

    # Test with enqueue_front
    deque3 = MyEpicDeque.enqueue_front(deque2, 99)
    assert MyEpicDeque.head(deque3) == 99, "Head should be front-enqueued element (99)"
    assert MyEpicDeque.tail(deque3) == 24, "Tail should still be last element (24)"

    IO.puts("✓ head/1 and tail/1 tests passed")
  end

  def test_to_list_from_list do
    IO.puts("\nTesting to_list/1 and from_list/1...")

    # From empty list
    deque1 = MyEpicDeque.from_list([])
    assert MyEpicDeque.empty(deque1) == true, "From empty list should create empty deque"
    assert MyEpicDeque.to_list(deque1) == [], "To list of empty deque should be empty"

    # From non-empty list
    original_list = [1, 2, 3, 4, 5]
    deque2 = MyEpicDeque.from_list(original_list)
    assert MyEpicDeque.to_list(deque2) == original_list, "Round-trip should preserve order"

    # Test that operations work on from_list created deques
    {{:ok, first}, deque3} = MyEpicDeque.dequeue(deque2)
    assert first == 1, "Should dequeue first element from from_list deque"
    assert MyEpicDeque.to_list(deque3) == [2, 3, 4, 5], "Should maintain order after dequeue"

    IO.puts("✓ to_list/1 and from_list/1 tests passed")
  end

  def test_combined_operations do
    IO.puts("\nTesting combined operations...")

    # Mix of front and rear operations
    deque = @empty_deque
    |> MyEpicDeque.enqueue(1)
    |> MyEpicDeque.enqueue_front(2)
    |> MyEpicDeque.enqueue(3)
    |> MyEpicDeque.enqueue_front(4)

    # Expected order: [4, 2, 1, 3]
    assert MyEpicDeque.to_list(deque) == [4, 2, 1, 3], "Mixed operations should create correct order"
    assert MyEpicDeque.head(deque) == 4, "Head should be 4"
    assert MyEpicDeque.tail(deque) == 3, "Tail should be 3"

    # Remove from both ends
    {{:ok, front_removed}, deque2} = MyEpicDeque.dequeue(deque)
    assert front_removed == 4, "Should remove front element 4"

    {{:ok, back_removed}, deque3} = MyEpicDeque.dequeue_back(deque2)
    assert back_removed == 3, "Should remove back element 3"

    assert MyEpicDeque.to_list(deque3) == [2, 1], "Remaining elements should be [2, 1]"

    IO.puts("✓ combined operations tests passed")
  end

  def test_edge_cases do
    IO.puts("\nTesting edge cases...")

    # Large number of elements
    large_list = Enum.to_list(1..1000)
    large_deque = MyEpicDeque.from_list(large_list)
    assert MyEpicDeque.to_list(large_deque) == large_list, "Should handle large lists"

    # Operations that trigger deque rebalancing
    deque = MyEpicDeque.from_list([1, 2, 3, 4, 5])
    {{:ok, _}, deque2} = MyEpicDeque.dequeue(deque)  # This triggers rebalancing
    assert MyEpicDeque.to_list(deque2) == [2, 3, 4, 5], "Should handle rebalancing correctly"

    {{:ok, _}, deque3} = MyEpicDeque.dequeue_back(deque2)  # This might trigger another rebalancing
    assert MyEpicDeque.to_list(deque3) == [2, 3, 4], "Should handle back rebalancing correctly"

    # Add elements after multiple removals
    deque4 = deque3
    |> MyEpicDeque.enqueue(99)
    |> MyEpicDeque.enqueue_front(88)
    assert MyEpicDeque.to_list(deque4) == [88, 2, 3, 4, 99], "Should work after multiple removals"

    IO.puts("✓ edge cases tests passed")
  end

  # Simple assertion helper
  defp assert(true, _message), do: :ok
  defp assert(false, message) do
    IO.puts("❌ Assertion failed: #{message}")
    raise "Test failed: #{message}"
  end
end

# Run the tests
MyEpicDequeTest.run_all_tests()
