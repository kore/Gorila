defmodule Gorila.Worker do
  use GenServer.Behaviour

  def start_link do
    :gen_server.start_link({ :local, :worker }, __MODULE__, [], [])
  end

  def handle_call({:port, port}, _from, state) do
    {:reply, {:gorila, Gorila.Server.listen(port)}, state}
  end
end
