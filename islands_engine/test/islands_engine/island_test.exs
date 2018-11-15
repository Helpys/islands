defmodule IslandEngine.IslandTest do
  use ExUnit.Case
  alias IslandsEngine.{Island, Coordinate}

  test "create empty island" do
    assert Island.new() == %IslandsEngine.Island{
             coordinates: MapSet.new(),
             hit_coordinates: MapSet.new()
           }
  end

  test "create dot island" do
    {:ok, coordinate} = Coordinate.new(1, 1)
    {:ok, island} = Island.new(:dot, coordinate)
    assert island.coordinates == MapSet.put(MapSet.new(), coordinate)
    assert island.coordinates == MapSet.put(MapSet.new(), elem(Coordinate.new(1, 1), 1))
  end

  test "try to create wrong island" do
    {:ok, coordinate} = Coordinate.new(1, 1)
    {:error, error} = Island.new(:wrong, coordinate)
    assert error == :invalid_island_type
  end

  test "overlapping islands" do
    {:ok, coordinate} = Coordinate.new(1, 1)
    {:ok, island_a} = Island.new(:dot, coordinate)
    {:ok, island_b} = Island.new(:dot, coordinate)
    assert Island.overlaps?(island_a, island_b) == true
  end

  test "non overlapping islands" do
    {:ok, coordinate_a} = Coordinate.new(1, 1)
    {:ok, coordinate_b} = Coordinate.new(1, 2)

    {:ok, island_a} = Island.new(:dot, coordinate_a)
    {:ok, island_b} = Island.new(:dot, coordinate_b)
    assert Island.overlaps?(island_a, island_b) == false
  end

  test "forested" do
    {:ok, coordinate} = Coordinate.new(1, 1)
    {:ok, island} = Island.new(:dot, coordinate)
    {:hit, island} = Island.guess(island, coordinate)
    assert Island.forested?(island) == true
  end

  test "not forested" do
    {:ok, coordinate} = Coordinate.new(1, 1)
    {:ok, island} = Island.new(:dot, coordinate)
    assert Island.forested?(island) == false
  end
end
