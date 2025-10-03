defmodule TemperatureServer do
  use GenServer

  @impl GenServer
  def init(_init_arg) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call(:something, from, state) do
    {:reply, :ok, state}
  end

end
