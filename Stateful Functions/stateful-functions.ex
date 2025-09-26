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
          send(caller, {:error, :must_insert_posotive_coins})
        else
        new_info = %{vending_machine_info | coins: vending_machine_info.coins + number_of_coins}
        send(caller, {:ok, new_info})
        loop(vending_machine_info)
      end
      {:cancel, caller} ->
        new_info = %{vending_machine_info | coins: 0}
        send(caller, {:return_coins, vending_machine_info.coins})
        loop(new_info)
      {:buy, shelf_number, caller} ->
        item = Enum.find(vending_machine_info.items, fn item -> item.shelf_number == shelf_number end)
        if item != nil do
          cond do
            item.count === 0 -> # Out of stock
              send(caller, {:error, :out_of_stock})
              loop(vending_machine_info)

            vending_machine_info.coins < item.cost -> # Not enough coins
              send(caller, {:error, :not_enough_coins})
              loop(vending_machine_info)

            vending_machine_info.coins === item.cost -> # YAY!
              new_items = Enum.map(vending_machine_info.items, fn item ->
                if item.shelf_number == shelf_number do
                  %{item | count: item.count - 1}
                end
              end)
              new_info = %{vending_machine_info | items: new_items, coins: 0}
              send(caller, {:ok, item})
              loop(new_info)
            vending_machine_info.coins > item.cost -> # return some of dem coins
              new_items = Enum.map(vending_machine_info.items, fn item ->
                if item.shelf_number == shelf_number do
                  %{item | count: item.count - 1}
                end
              end)
              new_info = %{vending_machine_info | items: new_items, coins: 0}
              number_of_extra_coins = vending_machine_info.coins - item.cost
              send(caller, {:extra_coins, item, number_of_extra_coins})
              loop(new_info)
          end
        else
        end
    end
  end
end

def start do
items = [
  %VendingItem{shelf_number: :a1, item_name: "Milky Way", cost: 4, count: 0},
  %VendingItem{shelf_number: :a2, item_name: "Milky Way", cost: 4, count: 5}
]
initial_info = %VendingMachineInfo{items: items, coins: 0}

machine = VendingMachine.start(initial_info)
send(machine, {:insert_coins, 5, self()})

receive do
  {:error, value} ->
    IO.inspect(value)
end
end
end

StatefulFunctions.start()
