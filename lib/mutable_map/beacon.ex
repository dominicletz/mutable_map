defmodule MutableMap.Beacon do
  @doc false
  use GenServer

  def start(:normal, _args) do
    start_link([])
  end

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init([]) do
    :ets.new(__MODULE__, [:set, :public, :named_table])
    {:ok, %{}}
  end

  def new_map_ref() do
    WeakRef.new(Process.whereis(__MODULE__))
  end

  @impl GenServer
  def handle_info({:DOWN, map_ref, :weak_ref}, state) do
    :ets.select_delete(__MODULE__, [{{{map_ref, :_}, :_}, [], [true]}])
    {:noreply, state}
  end
end
