defmodule GorilaServer do
  @behaviour :gen_server

  def listen(port) do
    IO.puts("Listen on port #{port}…")
    {:ok, socket} = :gen_tcp.listen(port, [:binary, {:packet, 0}, {:active, false}, {:reuseaddr, true}])
    accept(socket)
  end

  defp accept(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client_socket} ->
        spawn(fn -> loop(client_socket) end)
        accept(socket)
      {:error, :einval} ->
        accept(socket)
      {:error, :closed} ->
        accept(socket)
      {:error, _reason} ->
        accept(socket)
    end
  end

  defp loop(client_socket) do
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, data} ->
        IO.puts("Received: " <> data)
        :ok = :gen_tcp.send(client_socket, data)

        loop(client_socket)
      {:error, :closed} ->
        :ok
    end
  end

  def init([]) do
    say("init", [])

    # Not sure if this is how it is supposed to work, seems wrong – does it use
    # the OTP stuff?
    listen(6667)
    {:ok, []}
  end

  def start() do
    :gen_server.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end

  def stop(module) do
    :gen_server.call(module, :stop)
  end

  def stop() do
    IO.puts("Stopping server…")
    stop(__MODULE__)
  end

  def state(module) do
    :gen_server.call(module, :state)
  end

  def state() do
    state(__MODULE__)
  end

  def handle_call(:stop, from, state) do
    say("stopping by ~p, state was ~p.", [from, state])
    {:stop, :normal, :stopped, state}
  end

  def handle_call(:state, from, state) do
    say("~p is asking for the state.", [from])
    {:reply, :state, state}
  end

  def handle_call(request, from, state) do
    say("call ~p, ~p, ~p.", [request, from, state])
    {:reply, :ok, state}
  end

  def handle_cast(msg, state) do
    say("cast ~p, ~p.", [msg, state])
    {:noreply, state}
  end

  def handle_info(info, state) do
    say("info ~p, ~p.", [info, state])
    {:noreply, state}
  end

  def terminate(reason, state) do
    say("terminate ~p, ~p", [reason, state])
    :ok
  end

  def code_change(old_vsn, state, extra) do
    say("code_change ~p, ~p, ~p", [old_vsn, state, extra])
    {:ok, state}
  end

  def say(format) do
    say(format, [])
  end

  def say(format, data) do
    :io.format("~p:~p: ~s~n", [__MODULE__, Process.self(), :io_lib.format(format, data)])
  end
end
