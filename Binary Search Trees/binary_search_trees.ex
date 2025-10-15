defmodule MyEpicBinarySearchTree do
  @moduledoc """
  An epic Binary Search Tree (BST) with the following structure:
  Empty BST: `nil`
  BST Example: `{5, nil, nil}`, `{5, {4, nil, nil}, nil`, etc.
  """

  @doc """
  Input: A BST
  Output: true if the BST is empty, false otherwise
  Empty BST == `nil`
  Incorrect empty BST values == `{nil, nil, nil}` and `{}`
  """
  def empty(bst), do: bst == nil

  @doc """
  Input: A BST and an element
  Output A new BST with the element added
  """
  def add(bst, element) do
    case bst do
      nil ->
        {element, nil, nil}

      {value, left, right} when element < value ->
        new_left = add(left, element)
        {value, new_left, right}

      {value, left, right} when element > value ->
        new_right = add(right, element)
        {value, left, new_right}

      _ ->
        bst
    end
  end

  @doc """
  Input: A BST and a value
  Output: true if the value is found, false otherwise
  """
  def contains(nil, _element), do: false
  def contains({value, _left, _right}, element) when element == value, do: true
  def contains({value, left, _right}, element) when element < value, do: contains(left, element)
  def contains({value, _left, right}, element) when element > value, do: contains(right, element)

  @doc """
  Input: A BST and an element
  Output: A new BST with the element removed
  """
  def remove(nil, _element), do: nil

  def remove({value, left, right}, element)
      when value == element and left == nil and right == nil,
      do: nil

  def remove({value, left, right}, element) when value == element and right == nil do
    max_left = max(left)
    {max_left, remove(left, max_left), nil}
  end

  def remove({value, left, right}, element) when value == element do
    min_right = min(right)
    {min_right, left, remove(right, min_right)}
  end

  def remove({value, left, right}, element) when element < value,
    do: {value, remove(left, element), right}

  def remove({value, left, right}, element) when element > value,
    do: {value, left, remove(right, element)}

  @doc """
  Input: A BST
  Output: The smallest element or `nil` if the tree is empty
  """
  def min(bst) when bst == nil, do: nil
  def min({value, left, _right}) when left == nil, do: value
  def min({_value, left, _right}), do: min(left)

  @doc """
  Input: A BST
  Output: the largest element or `nil` if the tree is empty
  """
  def max(bst) when bst == nil, do: nil
  def max({value, _left, right}) when right == nil, do: value
  def max({_value, _left, right}), do: max(right)

  @doc """
  Input: A BST
  Output: The height as an integer
  """
  def height(nil), do: 0
  def height({_value, left, right}) when left == nil and right == nil, do: 1

  def height({_value, left, right}) do
    left_height = height(left)
    right_height = height(right)
    max = Kernel.max(left_height, right_height)
    max + 1
  end

  @doc """
  Input: A list of elements
  Output: A BST
  note: I'm assuming that it doesn't need to be sorted
  """
  def to_list(nil), do: []
  def to_list({value, left, right}), do: List.flatten([value] ++ to_list(left) ++ to_list(right))

  @doc """
  Input: A BST
  Output: A list of elements
  note: I'm assuming that it doesn't need to be balanced
  """
  def from_list([]), do: nil

  def from_list([h | t]), do: from_list(t, {h, nil, nil})

  def from_list([], bst), do: bst

  def from_list([h | t], bst) do
    from_list(t, add(bst, h))
  end

  @doc """
  Input: A BST
  Output: true if the tree is balanced, false otherwise
  I'm assuming that an empty tree is balanced. Can't be unbalanaced if there's nothing to unbalance it 🤷‍♂️
  I'm also assuming we only care that the root node is balanced, and not if any children are balanced
  """
  def is_balanced(nil), do: true
  def is_balanced({_value, left, right}), do: height(left) == height(right)
end

ExUnit.start()

defmodule MyEpicBinarySearchTreeTest do
  use ExUnit.Case
  alias MyEpicBinarySearchTree, as: BST

  ### EMPTY ###

  test "empty true" do
    bst = nil
    assert BST.empty(bst) == true
  end

  test "empty false" do
    assert BST.empty({4, nil, nil}) == false
  end

  ### ADD ###

  test "Add left" do
    element = 4
    bst = {5, nil, nil}
    new_bst = BST.add(bst, element)
    assert new_bst == {5, {4, nil, nil}, nil}
  end

  test "Add right" do
    assert BST.add({5, nil, nil}, 6) == {5, nil, {6, nil, nil}}
  end

  ### CONTAINS

  test "contains true" do
    bst = {4, nil, {5, nil, nil}}
    assert BST.contains(bst, 5) == true
  end

  test "contains false" do
    bst = {4, nil, {5, {6, nil, nil}, nil}}
    assert BST.contains(bst, 3) == false
  end

  ### REMOVE ###

  test "remove left" do
    bst = {4, nil, {5, {6, nil, nil}, nil}}
    assert BST.remove(bst, 5) == {4, nil, {6, nil, nil}}
  end

  test "remove right" do
    bst = {4, {3, {2, nil, nil}, nil}, {5, nil, nil}}
    assert BST.remove(bst, 3) == {4, {2, nil, nil}, {5, nil, nil}}
  end

  test "remove center" do
    bst = {4, {3, nil, nil}, {5, nil, {10, nil, nil}}}
    assert BST.remove(bst, 4) == {5, {3, nil, nil}, {10, nil, nil}}
  end

  test "remove center no left" do
    bst = {4, nil, {5, nil, nil}}
    assert BST.remove(bst, 4) == {5, nil, nil}
  end

  test "remove center no right" do
    bst = {4, {3, nil, nil}, nil}
    assert BST.remove(bst, 4) == {3, nil, nil}
  end

  ### MIN ###

  test "min empty" do
    assert BST.min(nil) == nil
  end

  test "min single node" do
    bst = {5, nil, nil}
    assert BST.min(bst) == 5
  end

  test "min left heavy" do
    bst = {5, {3, {1, nil, nil}, nil}, nil}
    assert BST.min(bst) == 1
  end

  test "min balanced" do
    bst = {5, {3, nil, nil}, {7, nil, nil}}
    assert BST.min(bst) == 3
  end

  ### MAX ###

  test "max empty" do
    assert BST.max(nil) == nil
  end

  test "max single node" do
    bst = {5, nil, nil}
    assert BST.max(bst) == 5
  end

  test "max right heavy" do
    bst = {5, nil, {7, nil, {9, nil, nil}}}
    assert BST.max(bst) == 9
  end

  test "max balanced" do
    bst = {5, {3, nil, nil}, {7, nil, nil}}
    assert BST.max(bst) == 7
  end

  ### TO LIST ###

  test "tolist" do
    bst = {5, {4, {3, nil, nil}, nil}, {6, nil, {7, nil, nil}}}
    assert BST.to_list(bst) == [5, 4, 3, 6, 7]
  end

  ### FROM LIST ###

  test "from list" do
    list = [4, 5, 3, 2, 1]
    assert BST.from_list(list) == {4, {3, {2, {1, nil, nil}, nil}, nil}, {5, nil, nil}}
  end

  ### HEIGHT ###

  test "hight empty bst" do
    assert BST.height(nil) == 0
  end

  test "height 1 bst" do
    bst = {5, nil, nil}
    assert BST.height(bst) == 1
  end

  test "height 5 bst" do
    bst = {1, {0, nil, nil}, {2, nil, {3, nil, {4, nil, {5, nil, nil}}}}}
    assert BST.height(bst) == 5
  end

  test "height 5 bst left" do
    bst =
      {6, {5, {4, {3, {2, nil, nil}, nil}, nil}, nil}, {7, nil, {8, nil, {9, nil, nil}}}}

    assert BST.height(bst) == 5
  end

  ### IS BALANCED ###
  test "is balanced true" do
    bst = {5, {4, nil, nil}, {6, nil, nil}}
    assert BST.is_balanced(bst) == true
  end

  test "is balanced false" do
    bst = {5, {4, nil, nil}, nil}
    assert BST.is_balanced(bst) == false
  end

  test "is balanced full tree false" do
    bst = {5, {4, {3, {2, nil, nil}, nil}, nil}, {9, {8, nil, nil}, nil}}
    assert BST.is_balanced(bst) == false
  end

  test "is balanced full tree true" do
    bst = {5, {4, {3, {2, nil, nil}, nil}, nil}, {9, {8, {7, nil, nil}, nil}, nil}}
    assert BST.is_balanced(bst) == true
  end
end
