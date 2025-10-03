defmodule TemperatureServer do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  # Public API

  def set_temp(temp) when is_integer(temp) do
    GenServer.cast(__MODULE__, {:add_temp, temp})
  end

  def get_average_temp() do
    GenServer.call(__MODULE__, :get_average_temp)
  end

  # GenServer Implementation
  @impl GenServer
  def init(_init_arg) do
    {:ok, []}
  end

  @impl GenServer
  def handle_cast({:add_temp, temp}, state) do
    {:noreply, state ++ [temp]}
  end

  @impl GenServer
  def handle_call(:get_average_temp, _from, state) do
    avg = Enum.sum(state) / Enum.count(state)
    {:reply, avg, state}
  end
end

{:ok, _} = GenServer.start_link(TemperatureServer, [], name: TemperatureServer)

TemperatureServer.set_temp(70)
TemperatureServer.set_temp(73)
TemperatureServer.set_temp(68)

IO.puts TemperatureServer.get_average_temp()

TemperatureServer.set_temp(50)
TemperatureServer.set_temp(42)

IO.puts TemperatureServer.get_average_temp()
