defmodule MyEpicTrie do
  # Empty
  def empty(trie) when is_map(trie), do: map_size(trie) == 0
  def empty(_), do: false

  # Add
  def add(trie, sequence) when is_binary(sequence),
    do: add(trie, String.to_charlist(sequence))

  def add(trie, []), do: Map.put(trie, :end, true)

  def add(trie, [head | tail]) do
    children = Map.get(trie, head, %{})
    new_children = add(children, tail)
    Map.put(trie, head, new_children)
  end

  # Contains
  def contains(trie, sequence) when is_binary(sequence),
    do: contains(trie, String.to_charlist(sequence))

  def contains(trie, []), do: Map.has_key?(trie, :end)

  def contains(trie, [head | tail]) do
    case Map.get(trie, head) do
      nil -> false
      child -> contains(child, tail)
    end
  end

  # Remove
  # Base case. No children.
  def remove(trie, sequence) when is_binary(sequence),
    do: remove(trie, String.to_charlist(sequence))

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

        if map_size(sub_trie_without_word) == 0 do
          Map.delete(trie, letter)
        else
          Map.put(trie, letter, sub_trie_without_word)
        end
    end
  end

  # Prefix
  def prefix(trie, prefix) when is_binary(prefix) do
    prefix(trie, String.to_charlist(prefix))
  end

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

  def to_list(trie), do: depth_first(trie, [], [])

  def from_list(list) do
    Enum.reduce(list, %{}, fn sequence, acc ->
      add(acc, normalize(sequence))
    end)
  end

  defp normalize(sequence) when is_binary(sequence), do: String.to_charlist(sequence)
  defp normalize(sequence) when is_list(sequence), do: sequence
end

# ~~~~~~~~~~~~~~~~~~~~~
#
#
# v These are the tests v
#
#
# ~~~~~~~~~~~~~~~~~~~~~

if Code.ensure_loaded?(ExUnit) do
  ExUnit.start()

  defmodule MyEpicTrieTest do
    use ExUnit.Case

    test "empty checks map size" do
      assert MyEpicTrie.empty(%{})

      trie = MyEpicTrie.add(%{}, ~c"cat")
      refute MyEpicTrie.empty(trie)
    end

    test "add and contains sequences" do
      trie =
        %{}
        |> MyEpicTrie.add(~c"cat")
        |> MyEpicTrie.add(~c"car")

      assert MyEpicTrie.contains(trie, ~c"cat")
      assert MyEpicTrie.contains(trie, ~c"car")
      refute MyEpicTrie.contains(trie, ~c"cap")
      assert MyEpicTrie.contains(trie, "cat")
    end

    test "prefix returns all completions" do
      trie =
        %{}
        |> MyEpicTrie.add(~c"cat")
        |> MyEpicTrie.add(~c"car")
        |> MyEpicTrie.add(~c"dog")

      assert Enum.sort(MyEpicTrie.prefix(trie, ~c"ca")) == ["car", "cat"]
      assert Enum.sort(MyEpicTrie.prefix(trie, "do")) == ["dog"]
      assert MyEpicTrie.prefix(trie, ~c"z") == []
    end

    test "remove respects shared prefixes" do
      trie =
        %{}
        |> MyEpicTrie.add(~c"car")
        |> MyEpicTrie.add(~c"card")

      updated = MyEpicTrie.remove(trie, ~c"car")

      refute MyEpicTrie.contains(updated, ~c"car")
      assert MyEpicTrie.contains(updated, ~c"card")
    end

    test "to_list collects all sequences" do
      trie =
        %{}
        |> MyEpicTrie.add(~c"cat")
        |> MyEpicTrie.add(~c"car")
        |> MyEpicTrie.add(~c"car")
        |> MyEpicTrie.add(~c"dog")

      assert Enum.sort(MyEpicTrie.to_list(trie)) == ["car", "cat", "dog"]
    end

    test "from_list builds trie from sequences" do
      sequences = [~c"alpha", ~c"alps", ~c"beta"]
      trie = MyEpicTrie.from_list(sequences)

      assert Enum.sort(MyEpicTrie.to_list(trie)) == ["alpha", "alps", "beta"]
      assert MyEpicTrie.contains(trie, ~c"alpha")
      refute MyEpicTrie.contains(trie, ~c"alp")
    end

    test "adding duplicate sequences only stores once" do
      trie =
        %{}
        |> MyEpicTrie.add(~c"cat")
        |> MyEpicTrie.add(~c"cat")

      assert MyEpicTrie.contains(trie, ~c"cat")
      assert MyEpicTrie.to_list(trie) == ["cat"]
    end

    test "handles empty sequence and empty prefix" do
      trie = MyEpicTrie.add(%{}, ~c"")

      assert MyEpicTrie.contains(trie, ~c"")
      assert MyEpicTrie.contains(trie, "")
      assert MyEpicTrie.to_list(trie) == [""]
      assert MyEpicTrie.prefix(trie, ~c"") == [""]

      updated = MyEpicTrie.remove(trie, ~c"")
      refute MyEpicTrie.contains(updated, ~c"")
    end
  end
end
