defmodule MutableMap.Beacon do
  @moduledoc false
  use GenServer

  def start(:normal, _args) do
    start_link([])
  end

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init([]) do
    {:ok, %{}}
  end

  def new_map_ref() do
    pid = Process.whereis(__MODULE__)
    {ref, id} = WeakRef.new(pid)
    ets = :ets.new(__MODULE__, [:set, :public])
    :ets.give_away(ets, pid, id)
    {ref, ets}
  end

  @impl GenServer
  def handle_info({:"ETS-TRANSFER", ets, _from_pid, id}, state) do
    {:noreply, Map.put(state, id, ets)}
  end

  @impl GenServer
  def handle_info({:DOWN, id, :weak_ref}, state) do
    {ets, state} = Map.pop!(state, id)
    :ets.delete(ets)
    {:noreply, state}
  end
end
