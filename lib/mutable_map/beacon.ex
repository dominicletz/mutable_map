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
    GenServer.call(__MODULE__, :new_map_ref)
  end

  @impl GenServer
  def handle_call(:new_map_ref, _from, state) do
    {ref, id} = WeakRef.new(Process.whereis(__MODULE__))
    ets = :ets.new(__MODULE__, [:set, :public])
    {:reply, {ref, ets}, Map.put(state, id, ets)}
  end

  @impl GenServer
  def handle_info({:DOWN, id, :weak_ref}, state) do
    {ets, state} = Map.pop!(state, id)
    :ets.delete(ets)
    {:noreply, state}
  end
end
