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
  def prefix(trie, prefix) do
    case find_node(trie, prefix) do
      :missing -> []
      node -> depth_first(node, prefix, [])
    end
  end

  defp find_node(trie, []), do: trie

  defp find_node(trie, [head | tail]) do
    case Map.get(trie, head) do
      nil -> :missing
      child -> find_node(child, tail)
    end
  end

  defp depth_first(trie, path, acc) do
    acc =
      if Map.has_key?(trie, :end) do
        [List.to_string(path) | acc]
      else
        acc
      end

    trie
    |> Map.delete(:end)
    |> Enum.reduce(acc, fn {head, child}, results ->
      depth_first(child, path ++ [head], results)
    end)
  end
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
