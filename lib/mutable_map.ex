defmodule MutableMap do
  @moduledoc """
  Documentation for `MutableMap`.
  """
  defstruct [:ref, :id]
  @table MutableMap.Beacon

  def new do
    {ref, id} = MutableMap.Beacon.new_map_ref()
    %MutableMap{ref: ref, id: id}
  end

  def new(list) do
    from_list(list)
  end

  def get(map, key, default \\ nil) do
    case :ets.lookup(@table, {map.id, key}) do
      [{_key, value}] -> value
      [] -> default
    end
  end

  def put(map, key, value) do
    :ets.insert(@table, {{map.id, key}, value})
    map
  end

  def put_new(map, key, value) do
    case :ets.lookup(@table, {map.id, key}) do
      [{_key, _value}] -> map
      [] -> put(map, key, value)
    end
  end

  def put_new_lazy(map, key, fun) do
    case :ets.lookup(@table, {map.id, key}) do
      [{_key, _value}] -> map
      [] -> put(map, key, fun.())
    end
  end

  def delete(map, key) do
    :ets.delete(@table, {map.id, key})
    map
  end

  def update(map, key, default, fun) do
    case :ets.lookup(@table, {map.id, key}) do
      [{_key, value}] -> put(map, key, fun.(value))
      [] -> put(map, key, default)
    end

    map
  end

  def keys(map) do
    :ets.select(@table, [{{{map.id, :"$1"}, :_}, [], [:"$1"]}])
  end

  def to_list(map) do
    :ets.select(MutableMap.Beacon, [{{{map.id, :"$1"}, :"$2"}, [], [{{:"$1", :"$2"}}]}])
  end

  def from_list(list) do
    Enum.reduce(list, new(), fn {key, value}, map -> put(map, key, value) end)
  end

  def size(map) do
    :ets.select_count(@table, [{{{map.id, :_}, :_}, [], [true]}])
  end

  def empty?(map) do
    size(map) == 0
  end

  def has_key?(map, key) do
    case get(map, key) do
      [{^key, _}] -> true
      [] -> false
    end
  end
end

defimpl Enumerable, for: MutableMap do
  def count(map) do
    {:ok, MutableMap.size(map)}
  end

  def member?(map, key) do
    {:ok, MutableMap.get(map, key) != []}
  end

  def reduce(map, acc, fun) do
    Enumerable.reduce(MutableMap.to_list(map), acc, fun)
  end

  def slice(_map) do
    {:error, __MODULE__}
  end
end
