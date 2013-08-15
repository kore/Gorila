defmodule Gorila do
  @bahaviour :application

  def start(_type, args) do
    :erlang.apply(GorilaServer, :start, args)
  end

  def stop(_state) do
    :ok
  end
end
