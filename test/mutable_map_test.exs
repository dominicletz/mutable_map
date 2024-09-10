defmodule MutableMapTest do
  use ExUnit.Case
  doctest MutableMap

  test "can create a new map" do
    assert %MutableMap{} = MutableMap.new()
  end

  test "basic map function get, put, update" do
    map = MutableMap.new()
    assert MutableMap.get(map, :a) == nil
    assert MutableMap.get(map, :a, :default) == :default
    assert %MutableMap{} = MutableMap.put(map, :a, 1)
    assert MutableMap.get(map, :a) == 1
    assert %MutableMap{} = MutableMap.update(map, :a, 0, &(&1 + 1))
    assert MutableMap.get(map, :a) == 2
    assert MutableMap.size(map) == 1

    assert %MutableMap{} = MutableMap.delete(map, :a)
    assert MutableMap.get(map, :a) == nil
    assert MutableMap.size(map) == 0
    assert MutableMap.empty?(map)
  end

  test "keys" do
    map = MutableMap.new()
    assert MutableMap.keys(map) == []
    assert %MutableMap{} = MutableMap.put(map, :a, 1)
    assert MutableMap.keys(map) == [:a]
    assert %MutableMap{} = MutableMap.put(map, :b, 2)
    assert Enum.sort(MutableMap.keys(map)) == [:a, :b]
  end

  test "enum protocol" do
    map = MutableMap.new()
    assert Enum.to_list(map) == []
    assert %MutableMap{} = MutableMap.put(map, :a, 1)
    assert Enum.to_list(map) == [{:a, 1}]
    assert %MutableMap{} = MutableMap.put(map, :b, 2)
    assert Enum.sort(Enum.to_list(map)) == [{:a, 1}, {:b, 2}]

    for {key, value} <- map do
      if key == :a do
        assert value == 1
      else
        assert value == 2
      end
    end
  end
end
