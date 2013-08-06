defmodule Gorila.Worker do
  use GenServer.Behaviour

  def start_link do
    IO.puts("Worker starts to link…")
    {:ok, pid} = :gen_server.start_link({ :local, :worker }, __MODULE__, [], [])
    :gen_server.call(pid, :pop)
  end

  def handle_call(:pop, _from, [h|t]) do
    { :reply, h, t }
  end

  def handle_call(_request, from, state) do
    {:reply, {:gorila, Gorila.Server.listen(6667)}, state}
  end
end
