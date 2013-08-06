defmodule Gorila.Server do
  def listen(port) do
    {:ok, l_socket} = :gen_tcp.listen(
      port,
      [:list, {:packet, 0}, {:active, false}, {:reuseaddr, true}]
    )
    IO.puts("Starting server")
    doListen(l_socket)
  end

  defp doListen(l_socket) do
    {:ok, socket} = :gen_tcp.accept(l_socket)
    spawn(fn() -> handleData(socket) end)
    doListen(l_socket)
  end

  defp handleData(socket) do
    case :gen_tcp.recv(socket, 0) do
      { :ok, data } ->
        IO.puts(data)
        :gen_tcp.send(socket, Gorila.Irc.Server.handle(data))
        handleData(socket)
      { :error, :closed } -> :ok
    end
  end
end
