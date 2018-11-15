defmodule IslandsEngine.ETSTest do
  use ExUnit.Case

  test "simple" do
    :ets.new(:test_table, [:public, :named_table])
    :ets.insert(:test_table, {:key, "value"})
    result = :ets.lookup(:test_table, :key)
    assert result == [key: "value"]
  end
end
