defmodule MyEpicTrie do
  # Empty
  def empty(%{}), do: true
  def empty(_), do: false

  # Add
  def add(trie, []), do: Map.put(trie, :end, true)

  def add(trie, [head | tail]) do
    children = Map.get(trie, head, %{})
    new_children = add(children, tail)
    Map.put(trie, head, new_children)
  end

  # Contains
  def contains(trie, []), do: false
  def contains(trie, [head | tail]) when trie[head] == nil, do: false
  def contains(trie, [head | tail]) when trie[head] == :end and tail == [], do: true

  def contains(trie, [head | tail]) do
    child_node = trie[head]
    contains(child_node, tail)
  end

  # Remove
  # Base case. No children.
  def remove(trie, []) do
    if trie[:end] do
      Map.delete(trie, :end)
    else
      trie
    end
  end

  def remove(trie, [letter | rest]) do
    case Map.get(trie, letter) do
      nil ->
        trie

      sub_trie ->
        sub_trie_without_word = remove(sub_trie, rest)

        if Map.size(sub_trie_without_word) == 0 do
          Map.delete(trie, letter)
        else
          Map.put(trie, letter, sub_trie_without_word)
        end
    end
  end

  # Prefix
  defp get_letters([]), do: []

  defp get_letters(trie) do
    Enum.map(trie, fn child -> get_letters(trie[child]) end)
  end

  # At the last letter
  def prefix(trie, [letter]) do
    get_letters(trie)
  end

  # Still more letters
  def prefix(trie, [letter | rest]) do
    children = trie[letter]
    prefix(children, rest)
  end

  # Start at the first letter
  # Go to the last letter
  # Find all children after the last letter
end

# Just so I understand the setup of a trie:
# 
# %{
#   "c" => %{
#     "a" => %{
#       "t" => %{
#         :end => true
#       },
#       "r" => %{
#         :end => true
#       }
#     }
#   }
# }
