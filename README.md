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


## Installation

The package can be installed by adding `mutable_map` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mutable_map, "~> 1.0"}
  ]
end
```

