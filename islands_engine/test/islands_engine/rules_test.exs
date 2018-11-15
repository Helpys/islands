defmodule IslandsEngine.RulesTest do
  use ExUnit.Case
  alias IslandsEngine.Rules

  test "test state" do
    rules = Rules.new()
    assert rules.state == :initialized
  end

  test "test set player" do
    rules = Rules.new()
    {:ok, rules} = Rules.check(rules, :add_player)
    assert rules.state == :players_set
  end

  test "test error state" do
    rules = Rules.new()
    return_value = Rules.check(rules, :foo)
    assert return_value == :error
  end

  test "test player set island" do
    rules = Rules.new()
    {:ok, rules} = Rules.check(rules, :add_player)
    {:ok, rules} = Rules.check(rules, {:position_island, :player1})
    assert rules.state == :players_set
  end

  test "test player set island player2" do
    rules = Rules.new()
    {:ok, rules} = Rules.check(rules, :add_player)
    {:ok, rules} = Rules.check(rules, {:position_island, :player2})
    assert rules.state == :players_set
  end

  test "test player set island player 1&2" do
    rules = Rules.new()
    {:ok, rules} = Rules.check(rules, :add_player)
    {:ok, rules} = Rules.check(rules, {:position_island, :player1})
    {:ok, rules} = Rules.check(rules, {:position_island, :player2})

    assert rules.state == :players_set
  end

  test "test player set islands" do
    rules = Rules.new()
    {:ok, rules} = Rules.check(rules, :add_player)
    {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    {:ok, rules} = Rules.check(rules, {:set_islands, :player2})

    assert rules.state == :player1_turn
  end
end
