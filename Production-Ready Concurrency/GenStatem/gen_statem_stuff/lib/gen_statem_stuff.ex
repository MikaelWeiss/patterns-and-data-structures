defmodule GenStatemStuff do
  @moduledoc """
  Documentation for `GenStatemStuff`.
  """
  use GenStateMachine, callback_mode: :state_functions
  use Application

  def init(_args) do
    {:ok, :idle, %{items: 0}}
  end

  def start(_type, _args) do
    IO.puts("\nStarting Warehouse Conveyor System...\n")
    {:ok, pid} = GenStateMachine.start_link(GenStatemStuff, [])

    GenStateMachine.cast(pid, :place_item)
    Process.sleep(100)
    GenStateMachine.cast(pid, :place_item)
    Process.sleep(100)
    GenStateMachine.cast(pid, :blockage_detected)
    Process.sleep(100)
    GenStateMachine.cast(pid, :blockage_cleared)
    Process.sleep(100)
    GenStateMachine.cast(pid, :item_completed)
    Process.sleep(100)
    GenStateMachine.cast(pid, :item_completed)
    Process.sleep(100)

    IO.puts("\nConveyor system test complete!\n")
    Supervisor.start_link([], strategy: :one_for_one)
  end

  # Idle
  def idle(:cast, :place_item, data) do
    new_data = %{data | items: data.items + 1}
    IO.puts("[IDLE -> MOVING] Item placed. Items on belt: #{new_data.items}")
    {:next_state, :moving_forward, new_data}
  end

  def idle(:cast, :error, data) do
    handle_error(data)
  end

  # Moving forward
  def moving_forward(:cast, :place_item, data) do
    new_data = %{data | items: data.items + 1}
    IO.puts("[MOVING] Item added. Items on belt: #{new_data.items}")
    {:next_state, :moving_forward, new_data}
  end

  def moving_forward(:cast, :item_completed, data) when data.items == 0 do
    IO.puts("[MOVING] Item completed but no items on belt - staying in MOVING")
    :keep_state_and_data
  end

  def moving_forward(:cast, :item_completed, data) when data.items == 1 do
    IO.puts("[MOVING -> IDLE] Last item completed. Belt is empty")
    {:next_state, :idle, %{data | items: 0}}
  end

  def moving_forward(:cast, :item_completed, data) do
    new_data = %{data | items: data.items - 1}
    IO.puts("[MOVING] Item completed. Items remaining: #{new_data.items}")
    {:next_state, :moving_forward, new_data}
  end

  def moving_forward(:cast, :blockage_detected, data) do
    IO.puts("[MOVING -> PAUSED] Blockage detected! Items on belt: #{data.items}")
    {:next_state, :paused, data}
  end

  def moving_forward(:cast, :error, data) do
    handle_error(data)
  end

  # Paused
  def paused({:call, from}, :get_status, data) do
    IO.puts("[PAUSED] Status requested: #{inspect(data)}")
    {:keep_state_and_data, [{:reply, from, {:paused, data}}]}
  end

  def paused(:cast, :blockage_cleared, data) do
    IO.puts("[PAUSED -> MOVING] Blockage cleared! Resuming. Items on belt: #{data.items}")
    {:next_state, :moving_forward, data}
  end

  def paused(:cast, :error, data) do
    handle_error(data)
  end

  defp handle_error(data) do
    IO.puts("Something bad happened...........")
    {:stop, :error, data}
  end
end
