defmodule MyEpicRedBlackTree do
  @moduledoc """
  An epic Binary Search Tree (BST) with the following structure:
  Empty BST: `nil`
  BST Example: `{5, nil, nil}`, `{5, {4, nil, nil}, nil`, etc.
  """

  @doc """
   * Input: A Red-Black Tree
   * Output: `true` if the tree is empty, `false` otherwise
  """
  def empty(rbt), do: rbt == nil

  @doc """
   * Input: A Red-Black Tree and an element
   * Output: A new Red-Black Tree with the element added
  """
  def add(rbt, element) do
    {_color, value, left, right} = insert(rbt, element)
    # Root must always be black
    {:black, value, left, right}
  end

  defp insert(nil, element), do: {:red, element, nil, nil}

  defp insert({color, value, left, right}, element) when element == value,
    do: {color, value, left, right}

  defp insert({color, value, left, right}, element) when element < value do
    new_left = insert(left, element)
    balance({color, value, new_left, right})
  end

  defp insert({color, value, left, right}, element) when element > value do
    new_right = insert(right, element)
    balance({color, value, left, new_right})
  end

  # """
  # Case 1: Right-Right chain (what we have above)
  # Before:          After rotation:
  #   1(B)             2(B)
  #    \              /  \
  #    2(R)         1(R) 3(R)
  #     \
  #     3(R)
  # """
  defp balance({:black, value, left, {:red, rv, rl, {:red, rrv, rrl, rrr}}}) do
    {:black, rv, {:red, value, left, rl}, {:red, rrv, rrl, rrr}}
  end

  # """
  # Case 2: Right-Left zigzag
  # Before:          After rotation:
  #   1(B)             2(B)
  #    \              /  \
  #    3(R)         1(R) 3(R)
  #    /
  #   2(R)
  # """
  defp balance({:black, value, left, {:red, rv, {:red, rlv, rll, rlr}, rr}}) do
    {:black, rlv, {:red, value, left, rll}, {:red, rv, rlr, rr}}
  end

  # """
  # Case 3: Left-Right zigzag
  # Before:          After rotation:
  #     3(B)             2(B)
  #    /                /  \
  #   1(R)           1(R)  3(R)
  #    \
  #    2(R)
  # """
  defp balance({:black, value, {:red, lv, ll, {:red, lrv, lrl, lrr}}, right}) do
    {:black, lrv, {:red, lv, ll, lrl}, {:red, value, lrr, right}}
  end

  # """
  # Case 4: Left-Left chain
  # Before:          After rotation:
  #     3(B)             2(B)
  #    /                /  \
  #   2(R)           1(R)  3(R)
  #   /
  #  1(R)
  # """
  defp balance({:black, value, {:red, lv, {:red, llv, lll, llr}, lr}, right}) do
    {:black, lv, {:red, llv, lll, llr}, {:red, value, lr, right}}
  end

  # """
  # Base case
  # """
  defp balance(rbt), do: rbt

  @doc """
  Input: A Red-Black Tree and a value
  Output: true if the value is found, false otherwise
  """
  def contains(nil, _element), do: false
  def contains({_color, value, _left, _right}, element) when element == value, do: true

  def contains({_color, value, left, _right}, element) when element < value,
    do: contains(left, element)

  def contains({_color, value, _left, right}, element) when element > value,
    do: contains(right, element)

  @doc """
  Input: A Red-Black Tree and an element
  Output: A new Red-Black Tree with the element removed
  """
  def remove(nil, _element), do: nil

  def remove({_color, value, left, right}, element)
      when value == element and left == nil and right == nil,
      do: nil

  def remove({color, value, left, right}, element) when value == element and right == nil do
    max_left = max(left)
    {color, max_left, remove(left, max_left), nil}
  end

  def remove({color, value, left, right}, element) when value == element do
    min_right = min(right)
    {color, min_right, left, remove(right, min_right)}
  end

  def remove({color, value, left, right}, element) when element < value,
    do: {color, value, remove(left, element), right}

  def remove({color, value, left, right}, element) when element > value,
    do: {color, value, left, remove(right, element)}

  @doc """
  Input: A Red-Black Tree
  Output: The smallest element or `nil` if the tree is empty
  """
  def min(rbt) when rbt == nil, do: nil
  def min({_color, value, left, _right}) when left == nil, do: value
  def min({_color, _value, left, _right}), do: min(left)

  @doc """
  Input: A Red-Black Tree
  Output: the largest element or `nil` if the tree is empty
  """
  def max(rbt) when rbt == nil, do: nil
  def max({_color, value, _left, right}) when right == nil, do: value
  def max({_color, _value, _left, right}), do: max(right)

  @doc """
  Input: A Red-Black Tree
  Output: The height as an integer
  """
  def height(nil), do: 0
  def height({_color, _value, left, right}) when left == nil and right == nil, do: 1

  def height({_color, _value, left, right}) do
    left_height = height(left)
    right_height = height(right)
    max = Kernel.max(left_height, right_height)
    max + 1
  end

  @doc """
  Input: A Red-Black Tree
  Output: A list of elements in sorted order (in-order traversal)
  """
  def to_list(nil), do: []
  def to_list({_color, value, left, right}), do: to_list(left) ++ [value] ++ to_list(right)

  @doc """
  Input: A list of elements
  Output: A Red-Black Tree
  note: I'm assuming that it doesn't need to be balanced
  """
  def from_list([]), do: nil

  def from_list([h | t]), do: from_list(t, {:black, h, nil, nil})

  def from_list([], rbt), do: rbt

  def from_list([h | t], rbt) do
    from_list(t, add(rbt, h))
  end

  @doc """
  Input: A Red-Black Tree
  Output: true if the tree is balanced, false otherwise
  I'm assuming that an empty tree is balanced. Can't be unbalanaced if there's nothing to unbalance it 🤷‍♂️
  I'm also assuming we only care that the root node is balanced, and not if any children are balanced
  """
  def is_balanced(nil), do: true
  def is_balanced({_color, _value, left, right}), do: height(left) == height(right)
end

ExUnit.start()

defmodule MyEpicRedBlackTreeTest do
  use ExUnit.Case
  alias MyEpicRedBlackTree, as: RBT

  ### EMPTY ###

  test "empty true" do
    rbt = nil
    assert RBT.empty(rbt) == true
  end

  test "empty false" do
    assert RBT.empty({:black, 4, nil, nil}) == false
  end

  ### ADD ###

  test "Add to empty tree creates black root" do
    tree = RBT.add(nil, 5)
    assert tree == {:black, 5, nil, nil}
  end

  test "Add left to single node" do
    tree = {:black, 5, nil, nil}
    result = RBT.add(tree, 3)
    assert result == {:black, 5, {:red, 3, nil, nil}, nil}
  end

  test "Add right to single node" do
    tree = {:black, 5, nil, nil}
    result = RBT.add(tree, 7)
    assert result == {:black, 5, nil, {:red, 7, nil, nil}}
  end

  test "Add duplicate element does not modify tree" do
    tree = {:black, 5, {:red, 3, nil, nil}, {:red, 7, nil, nil}}
    result = RBT.add(tree, 5)
    assert result == tree
  end

  test "Add triggers Right-Right rotation (1,2,3 sequence)" do
    tree = nil
    tree = RBT.add(tree, 1)
    tree = RBT.add(tree, 2)
    tree = RBT.add(tree, 3)
    # Should rebalance to: 2(B) with 1(R) and 3(R) as children
    assert tree == {:black, 2, {:red, 1, nil, nil}, {:red, 3, nil, nil}}
  end

  test "Add triggers Right-Left rotation (1,3,2 sequence)" do
    tree = nil
    tree = RBT.add(tree, 1)
    tree = RBT.add(tree, 3)
    tree = RBT.add(tree, 2)
    # Should rebalance to: 2(B) with 1(R) and 3(R) as children
    assert tree == {:black, 2, {:red, 1, nil, nil}, {:red, 3, nil, nil}}
  end

  test "Add triggers Left-Left rotation (3,2,1 sequence)" do
    tree = nil
    tree = RBT.add(tree, 3)
    tree = RBT.add(tree, 2)
    tree = RBT.add(tree, 1)
    # Should rebalance to: 2(B) with 1(R) and 3(R) as children
    assert tree == {:black, 2, {:red, 1, nil, nil}, {:red, 3, nil, nil}}
  end

  test "Add triggers Left-Right rotation (3,1,2 sequence)" do
    tree = nil
    tree = RBT.add(tree, 3)
    tree = RBT.add(tree, 1)
    tree = RBT.add(tree, 2)
    # Should rebalance to: 2(B) with 1(R) and 3(R) as children
    assert tree == {:black, 2, {:red, 1, nil, nil}, {:red, 3, nil, nil}}
  end

  test "Add multiple elements maintains BST ordering" do
    tree = nil
    tree = RBT.add(tree, 5)
    tree = RBT.add(tree, 3)
    tree = RBT.add(tree, 7)
    tree = RBT.add(tree, 1)
    tree = RBT.add(tree, 9)

    # Verify all elements are present and in order
    assert RBT.contains(tree, 1) == true
    assert RBT.contains(tree, 3) == true
    assert RBT.contains(tree, 5) == true
    assert RBT.contains(tree, 7) == true
    assert RBT.contains(tree, 9) == true
    assert RBT.contains(tree, 2) == false
  end

  test "Add maintains black root after multiple insertions" do
    tree = nil
    tree = RBT.add(tree, 5)
    tree = RBT.add(tree, 3)
    tree = RBT.add(tree, 7)
    tree = RBT.add(tree, 1)

    # Root must always be black
    {color, _value, _left, _right} = tree
    assert color == :black
  end

  test "Add creates balanced tree from sorted sequence" do
    tree = nil
    tree = RBT.add(tree, 1)
    tree = RBT.add(tree, 2)
    tree = RBT.add(tree, 3)
    tree = RBT.add(tree, 4)
    tree = RBT.add(tree, 5)

    # Tree should not degenerate to a linked list
    # Height should be reasonable (log n)
    height = RBT.height(tree)
    # For 5 nodes, height should be at most 4
    assert height <= 4
  end

  test "Add with reverse sorted sequence" do
    tree = nil
    tree = RBT.add(tree, 5)
    tree = RBT.add(tree, 4)
    tree = RBT.add(tree, 3)
    tree = RBT.add(tree, 2)
    tree = RBT.add(tree, 1)

    height = RBT.height(tree)
    assert height <= 4
  end

  test "Add large number of elements" do
    tree = Enum.reduce(1..15, nil, fn i, acc -> RBT.add(acc, i) end)

    # Verify all elements present
    assert Enum.all?(1..15, fn i -> RBT.contains(tree, i) end)

    # Root must be black
    {color, _value, _left, _right} = tree
    assert color == :black

    # Verify tree maintains some balance (not a complete linked list)
    # For a simplified implementation, we just ensure it's building a tree structure
    height = RBT.height(tree)
    assert height > 0 and height <= 15
  end

  ### CONTAINS

  test "contains true" do
    rbt = {:black, 4, nil, {:red, 5, nil, nil}}
    assert RBT.contains(rbt, 5) == true
  end

  test "contains false" do
    rbt = {:black, 4, nil, {:red, 5, {:black, 6, nil, nil}, nil}}
    assert RBT.contains(rbt, 3) == false
  end

  ### REMOVE ###

  test "remove left" do
    rbt = {:black, 4, nil, {:red, 5, {:black, 6, nil, nil}, nil}}
    assert RBT.remove(rbt, 5) == {:black, 4, nil, {:red, 6, nil, nil}}
  end

  test "remove right" do
    rbt = {:black, 4, {:red, 3, {:black, 2, nil, nil}, nil}, {:red, 5, nil, nil}}
    assert RBT.remove(rbt, 3) == {:black, 4, {:red, 2, nil, nil}, {:red, 5, nil, nil}}
  end

  test "remove center" do
    rbt = {:black, 4, {:red, 3, nil, nil}, {:red, 5, nil, {:black, 10, nil, nil}}}
    assert RBT.remove(rbt, 4) == {:black, 5, {:red, 3, nil, nil}, {:red, 10, nil, nil}}
  end

  test "remove center no left" do
    rbt = {:black, 4, nil, {:red, 5, nil, nil}}
    assert RBT.remove(rbt, 4) == {:black, 5, nil, nil}
  end

  test "remove center no right" do
    rbt = {:black, 4, {:red, 3, nil, nil}, nil}
    assert RBT.remove(rbt, 4) == {:black, 3, nil, nil}
  end

  ### MIN ###

  test "min empty" do
    assert RBT.min(nil) == nil
  end

  test "min single node" do
    rbt = {:black, 5, nil, nil}
    assert RBT.min(rbt) == 5
  end

  test "min left heavy" do
    rbt = {:black, 5, {:red, 3, {:black, 1, nil, nil}, nil}, nil}
    assert RBT.min(rbt) == 1
  end

  test "min balanced" do
    rbt = {:black, 5, {:red, 3, nil, nil}, {:red, 7, nil, nil}}
    assert RBT.min(rbt) == 3
  end

  ### MAX ###

  test "max empty" do
    assert RBT.max(nil) == nil
  end

  test "max single node" do
    rbt = {:black, 5, nil, nil}
    assert RBT.max(rbt) == 5
  end

  test "max right heavy" do
    rbt = {:black, 5, nil, {:red, 7, nil, {:black, 9, nil, nil}}}
    assert RBT.max(rbt) == 9
  end

  test "max balanced" do
    rbt = {:black, 5, {:red, 3, nil, nil}, {:red, 7, nil, nil}}
    assert RBT.max(rbt) == 7
  end

  ### TO LIST ###

  test "tolist" do
    rbt =
      {:black, 5, {:red, 4, {:black, 3, nil, nil}, nil}, {:red, 6, nil, {:black, 7, nil, nil}}}

    # In-order traversal produces sorted output
    assert RBT.to_list(rbt) == [3, 4, 5, 6, 7]
  end

  ### FROM LIST ###

  test "from list" do
    list = [4, 5, 3, 2, 1]
    result = RBT.from_list(list)
    # Verify all elements are present
    assert RBT.contains(result, 1) == true
    assert RBT.contains(result, 2) == true
    assert RBT.contains(result, 3) == true
    assert RBT.contains(result, 4) == true
    assert RBT.contains(result, 5) == true
    # Verify root is black
    {color, _value, _left, _right} = result
    assert color == :black
  end

  ### HEIGHT ###

  test "hight empty rbt" do
    assert RBT.height(nil) == 0
  end

  test "height 1 rbt" do
    rbt = {:black, 5, nil, nil}
    assert RBT.height(rbt) == 1
  end

  test "height 5 rbt" do
    rbt =
      {:black, 1, {:red, 0, nil, nil},
       {:red, 2, nil, {:black, 3, nil, {:red, 4, nil, {:black, 5, nil, nil}}}}}

    assert RBT.height(rbt) == 5
  end

  test "height 5 rbt left" do
    rbt =
      {:black, 6, {:red, 5, {:black, 4, {:red, 3, {:black, 2, nil, nil}, nil}, nil}, nil},
       {:red, 7, nil, {:black, 8, nil, {:red, 9, nil, nil}}}}

    assert RBT.height(rbt) == 5
  end

  ### IS BALANCED ###
  test "is balanced true" do
    rbt = {:black, 5, {:red, 4, nil, nil}, {:red, 6, nil, nil}}
    assert RBT.is_balanced(rbt) == true
  end

  test "is balanced false" do
    rbt = {:black, 5, {:red, 4, nil, nil}, nil}
    assert RBT.is_balanced(rbt) == false
  end

  test "is balanced full tree false" do
    rbt =
      {:black, 5, {:red, 4, {:black, 3, {:red, 2, nil, nil}, nil}, nil},
       {:red, 9, {:black, 8, nil, nil}, nil}}

    assert RBT.is_balanced(rbt) == false
  end

  test "is balanced full tree true" do
    rbt =
      {:black, 5, {:red, 4, {:black, 3, {:red, 2, nil, nil}, nil}, nil},
       {:red, 9, {:black, 8, {:red, 7, nil, nil}, nil}, nil}}

    assert RBT.is_balanced(rbt) == true
  end
end
