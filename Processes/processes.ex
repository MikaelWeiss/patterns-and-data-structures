defmodule StatefulFunctions do
defmodule VendingMachineInfo do
  defstruct items: [VendingItem], coins: 0
end

defmodule VendingItem do
  defstruct shelf_number: nil, item_name: nil, cost: 0, count: 0
end

defmodule VendingMachine do
  def start(initial_info) do
    spawn(fn -> loop(initial_info) end)
  end

  defp loop(vending_machine_info) do
    receive do
      {:insert_coins, number_of_coins, caller} ->
        if number_of_coins < 1 do
          send(caller, {:error, :must_insert_positive_coins})
          loop(vending_machine_info)
        else
          new_info = %{vending_machine_info | coins: vending_machine_info.coins + number_of_coins}
          send(caller, {:ok, new_info})
          loop(new_info)
        end

      {:cancel, caller} ->
        new_info = %{vending_machine_info | coins: 0}
        send(caller, {:return_coins, vending_machine_info.coins})
        loop(new_info)

      {:buy, shelf_number, caller} ->
        item = Enum.find(vending_machine_info.items, fn item -> item.shelf_number == shelf_number end)
        if item != nil do
          cond do
            item.count === 0 ->
              send(caller, {:error, :out_of_stock})
              loop(vending_machine_info)

            vending_machine_info.coins < item.cost ->
              send(caller, {:error, :not_enough_coins})
              loop(vending_machine_info)

            vending_machine_info.coins === item.cost ->
              new_items = Enum.map(vending_machine_info.items, fn existing_item ->
                if existing_item.shelf_number == shelf_number do
                  %{existing_item | count: existing_item.count - 1}
                else
                  existing_item
                end
              end)
              new_info = %{vending_machine_info | items: new_items, coins: 0}
              send(caller, {:ok, item})
              loop(new_info)

            vending_machine_info.coins > item.cost ->
              new_items = Enum.map(vending_machine_info.items, fn existing_item ->
                if existing_item.shelf_number == shelf_number do
                  %{existing_item | count: existing_item.count - 1}
                else
                  existing_item
                end
              end)
              new_info = %{vending_machine_info | items: new_items, coins: 0}
              number_of_extra_coins = vending_machine_info.coins - item.cost
              send(caller, {:extra_coins, item, number_of_extra_coins})
              loop(new_info)
          end
        else
          send(caller, {:error, :item_not_found})
          loop(vending_machine_info)
        end

      {:terminate} ->
        IO.puts("Machine shutting down...")
        exit(:normal)
    end
  end
end

def start do
items = [
  %VendingItem{shelf_number: :a1, item_name: "Milky Way", cost: 4, count: 0},
  %VendingItem{shelf_number: :a2, item_name: "Milky Way", cost: 4, count: 5},
  %VendingItem{shelf_number: :a3, item_name: "Snickers", cost: 3, count: 2}
]
initial_info = %VendingMachineInfo{items: items, coins: 0}

machine = VendingMachine.start(initial_info)
IO.puts("Starting vending machine tests...")
IO.puts("Initial machine state: #{inspect(initial_info)}")

# Test 1: Insert coins successfully
IO.puts("\n--- Test 1: Insert coins ---")
send(machine, {:insert_coins, 5, self()})
receive do
  {:ok, new_info} ->
    IO.puts("Successfully inserted coins. New info: #{inspect(new_info)}")
  {:error, reason} ->
    IO.puts("Error inserting coins: #{inspect(reason)}")
end

# Test 2: Try to buy item that's out of stock
IO.puts("\n--- Test 2: Try to buy out of stock item ---")
send(machine, {:buy, :a1, self()})
receive do
  {:error, reason} ->
    IO.puts("Expected error for out of stock: #{inspect(reason)}")
  {:ok, item} ->
    IO.puts("Unexpected success: #{inspect(item)}")
end

# Test 3: Cancel previous coins and buy item with exact change
IO.puts("\n--- Test 3: Cancel and buy item with exact change ---")
send(machine, {:cancel, self()})
receive do
  {:return_coins, coins} ->
    IO.puts("Cancelled previous transaction, returned #{coins} coins")
end

send(machine, {:insert_coins, 4, self()})
receive do
  {:ok, _} -> IO.puts("Coins inserted successfully")
  {:error, reason} -> IO.puts("Error inserting coins: #{inspect(reason)}")
end

send(machine, {:buy, :a2, self()})
receive do
  {:ok, item} ->
    IO.puts("Successfully bought item: #{inspect(item)}")
  {:error, reason} ->
    IO.puts("Error buying item: #{inspect(reason)}")
end

# Test 4: Buy item with extra coins
IO.puts("\n--- Test 4: Buy item with extra coins ---")
send(machine, {:insert_coins, 5, self()})
receive do
  {:ok, _} -> IO.puts("Coins inserted successfully")
  {:error, reason} -> IO.puts("Error inserting coins: #{inspect(reason)}")
end

send(machine, {:buy, :a3, self()})
receive do
  {:extra_coins, item, extra} ->
    IO.puts("Bought item: #{inspect(item)}, received #{extra} coins back")
  {:error, reason} ->
    IO.puts("Error buying item: #{inspect(reason)}")
end

# Test 5: Cancel transaction
IO.puts("\n--- Test 5: Cancel transaction ---")
send(machine, {:insert_coins, 2, self()})
receive do
  {:ok, _} -> IO.puts("Coins inserted successfully")
  {:error, reason} -> IO.puts("Error inserting coins: #{inspect(reason)}")
end

send(machine, {:cancel, self()})
receive do
  {:return_coins, coins} ->
    IO.puts("Transaction cancelled, returned #{coins} coins")
end

IO.puts("\nAll tests completed. Terminating machine...")
send(machine, {:terminate})

# Allow some time for the machine to terminate
:timer.sleep(100)
IO.puts("Machine terminated successfully.")
end
end

StatefulFunctions.start()
