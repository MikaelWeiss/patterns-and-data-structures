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
