defmodule MySupervisor do
  use Supervisor

  def start_link(_init_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      %{
        id: MyWorker,
        start: {MyWorker, :start_link, [[]]},
        restart: :permanent
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule MyWorker do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    start_time = DateTime.utc_now()
    IO.puts("Worker Started")
    {:ok, %{start_time: start_time}}
  end

  def terminate(_reason, state) do
    uptime = DateTime.diff(DateTime.utc_now(), state.start_time)
    IO.puts("Uptime: #{uptime}")
  end

  def handle_call(:crash, _from, _state) do
    raise "This crash is 100% on purpose"
  end
end

children = [
  MySupervisor
]

Supervisor.start_link(children, strategy: :one_for_one)

:timer.sleep(3000)

try do
  GenServer.call(MyWorker, :crash)
catch
  :exit, _ -> IO.puts("Worker crashed as expected")
end

Supervisor.stop(MySupervisor)

IO.puts("Everything ran!")
