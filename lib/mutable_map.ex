defmodule MutableMap do
  @moduledoc """
  Documentation for `MutableMap`.
  """
  defstruct [:ref, :table]
  @type t :: %MutableMap{ref: reference(), table: reference()}

  def new() do
    {ref, ets} = MutableMap.Beacon.new_map_ref()
    %MutableMap{ref: ref, table: ets}
  end

  def new(list) when is_list(list) do
    import_list(new(), list)
  end

  def new(other) do
    import_list(new(), Enum.to_list(other))
  end

  def get(map, key, default \\ nil) do
    case :ets.lookup(map.table, key) do
      [{_key, value}] -> value
      [] -> default
    end
  end

  def put(map, key, value) do
    :ets.insert(map.table, {key, value})
    map
  end

  def put_new(map, key, value) do
    case :ets.lookup(map.table, key) do
      [{_key, _value}] -> map
      [] -> put(map, key, value)
    end
  end

  def put_new_lazy(map, key, fun) do
    case :ets.lookup(map.table, key) do
      [{_key, _value}] -> map
      [] -> put(map, key, fun.())
    end
  end

  def delete(map, key) do
    :ets.delete(map.table, key)
    map
  end

  def update(map, key, default, fun) do
    case :ets.lookup(map.table, key) do
      [{_key, value}] -> put(map, key, fun.(value))
      [] -> put(map, key, default)
    end

    map
  end

  def keys(map) do
    :ets.select(map.table, [{{:"$1", :_}, [], [:"$1"]}])
  end

  def to_list(map) do
    :ets.select(map.table, [{{:"$1", :"$2"}, [], [{{:"$1", :"$2"}}]}])
  end

  def import_list(map, list) do
    :ets.insert(map.table, list)
    map
  end

  def size(map) do
    :ets.select_count(map.table, [{{:_, :_}, [], [true]}])
  end

  def empty?(map) do
    size(map) == 0
  end

  def has_key?(map, key) do
    :ets.lookup(map.table, key) != []
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
