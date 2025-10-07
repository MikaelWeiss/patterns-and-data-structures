defmodule GenStatemStuff do
  @moduledoc """
  Documentation for `GenStatemStuff`.
  """
  use GenStateMachine, callback_mode: :state_functions
  use Application

  def start(_type, _args) do
    {:ok, pid} = GenStateMachine.start_link(GenStatemStuff, {:idle, :place_item})

    GenStateMachine.cast(pid, :place_item)
    GenStateMachine.cast(pid, :place_item)

    GenStateMachine.cast(pid, :get_status)

    Supervisor.start_link([], strategy: :one_for_one)
  end

  # Idle
  def idle(:cast, :place_item, data) do
    {:next_state, :moving_forward, %{data | items: data.items + 1}}
  end

  def idle(:cast, :error, data) do
    handle_error(data)
  end

  # Moving forward
  def moving_forward(:cast, :place_item, data) do
    {:next_state, :moving_forward, %{data | items: data.items + 1}}
  end

  def moving_forward(:cast, :item_completed, data) when data.items == 0 do
    :keep_state_and_data
  end

  def moving_forward(:cast, :item_completed, data) do
    {:next_state, :moving_forward, %{data | items: data.items - 1}}
  end

  def moving_forward(:cast, :error, data) do
    handle_error(data)
  end

  # Paused
  def puased({:call, from}, :get_status, data) do
    {:keep_state_and_data, [{:reply, from, {:paused, data}}]}
  end

  def paused(:cast, :error, data) do
    handle_error(data)
  end

  defp handle_error(data) do
    IO.puts("Something bad happened...........")
    {:stop, :error, data}
  end
end
