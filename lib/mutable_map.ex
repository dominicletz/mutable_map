defmodule MutableMap do
  @moduledoc """
  # MutableMap

  Large, no worries mutable maps for Elixir. These `MutableMap`s can be used as drop-in replacements for `Map`s, but can also be used as a shared, mutable, concurrent data store.

  Multiple processes can safely read and write to the same `MutableMap` without the need for locking or other synchronization mechanisms. When no process is using the `MutableMap` anymore, it is automatically garbage collected like normal Elixir Maps.

  ## Motivation

  When working with large data sets, Elixir's `Map`s and `Keyword`s can become unwieldy. E.g. when using large maps (200mb+) then sending them between processes becomes really slow (Easily 50ms and more for one `send(pid, large_map)`). On the other hand Erlang `:ets` tables can solve this problem, but their API is unwieldy and they require explicit creation and cleaning up.

  Instead `MutableMap`s offer an easy to use, performant and most importantly lazy garbage collected data storage solution.

  ## Usage

  ```elixir
  # Create a new MutableMap
  MutableMap.new()

  # Create a new MutableMap from a list
  MutableMap.new([{1, 2}, {3, 4}])

  # Set and get values
  MutableMap.put(map, 1, 2)
  MutableMap.get(map, 1)

  # Delete values
  MutableMap.delete(map, 1)

  # Since MutableMaps are mutable they can be explicitly copied to create different instances

  map1 = MutableMap.new()
  map2 = map1
  MutableMap.put(map1, :a, 1)
  MutableMap.to_list(map1)
  # => [:a, 1]
  MutableMap.to_list(map2)
  # => [:a, 1]
  map3 = MutableMap.new(map1)
  MutableMap.put(map3, :b, 2)
  MutableMap.to_list(map1)
  # => [:a, 1]
  MutableMap.to_list(map3) |> Enum.sort()
  # => [:a, 1, :b, 2]
  ```
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
