defmodule IslandsEngine.GameTest do
  use ExUnit.Case

  test "init game" do
    {:ok, game} = IslandsEngine.Game.start_link("Foo1")
    game_state = :sys.get_state(game)
    assert game_state.player1.name == "Foo1"
  end

  test "add player 2" do
    {:ok, game} = IslandsEngine.Game.start_link("Foo2")
    assert Process.alive?(game) == true
    game_state = :sys.get_state(game)
    assert game_state.rules.state == :initialized
    IslandsEngine.Game.add_player(game, "Bar1")

    game_state = :sys.get_state(game)
    assert game_state.player2.name == "Bar1"
  end

  test "beahve test" do
    {:ok, game} = IslandsEngine.Game.start_link("Foo3")
    :ok = IslandsEngine.Game.add_player(game, "Bar")
    :ok = IslandsEngine.Game.position_island(game, :player1, :square, 1, 1)
  end

  test "beahve wrong" do
    {:ok, game} = IslandsEngine.Game.start_link("Foo4")
    :ok = IslandsEngine.Game.add_player(game, "Bar")
    return = IslandsEngine.Game.position_island(game, :player1, :square, 100, 100)
    assert return == {:error, :invalidate_coordinate}
  end

  test "set all islands player 1" do
    {:ok, game} = IslandsEngine.Game.start_link("Foo5")
    :ok = IslandsEngine.Game.add_player(game, "Bar")
    IslandsEngine.Game.position_island(game, :player1, :atoll, 1, 1)
    IslandsEngine.Game.position_island(game, :player1, :dot, 1, 4)
    IslandsEngine.Game.position_island(game, :player1, :l_shape, 1, 5)
    IslandsEngine.Game.position_island(game, :player1, :s_shape, 5, 1)
    IslandsEngine.Game.position_island(game, :player1, :square, 5, 5)

    {a, _b} = IslandsEngine.Game.set_islands(game, :player1)
    assert a == :ok
  end

  test "guess coordinate miss" do
    {:ok, game} = IslandsEngine.Game.start_link("Foo6")
    :ok = IslandsEngine.Game.add_player(game, "Bar")
    IslandsEngine.Game.position_island(game, :player1, :atoll, 1, 1)
    IslandsEngine.Game.position_island(game, :player1, :dot, 1, 4)
    IslandsEngine.Game.position_island(game, :player1, :l_shape, 1, 5)
    IslandsEngine.Game.position_island(game, :player1, :s_shape, 5, 1)
    IslandsEngine.Game.position_island(game, :player1, :square, 5, 5)
    IslandsEngine.Game.set_islands(game, :player1)
    IslandsEngine.Game.position_island(game, :player2, :atoll, 1, 1)
    IslandsEngine.Game.position_island(game, :player2, :dot, 1, 4)
    IslandsEngine.Game.position_island(game, :player2, :l_shape, 1, 5)
    IslandsEngine.Game.position_island(game, :player2, :s_shape, 5, 1)
    IslandsEngine.Game.position_island(game, :player2, :square, 5, 5)
    IslandsEngine.Game.set_islands(game, :player2)

    a = IslandsEngine.Game.guess_coordinate(game, :player1, 8, 8)
    assert {:miss, :none, :no_win} == a
  end

  test "guess coordinate hit" do
    {:ok, game} = IslandsEngine.Game.start_link("Foo7")
    :ok = IslandsEngine.Game.add_player(game, "Bar")
    IslandsEngine.Game.position_island(game, :player1, :atoll, 1, 1)
    IslandsEngine.Game.position_island(game, :player1, :dot, 1, 4)
    IslandsEngine.Game.position_island(game, :player1, :l_shape, 1, 5)
    IslandsEngine.Game.position_island(game, :player1, :s_shape, 5, 1)
    IslandsEngine.Game.position_island(game, :player1, :square, 5, 5)
    IslandsEngine.Game.set_islands(game, :player1)
    IslandsEngine.Game.position_island(game, :player2, :atoll, 1, 1)
    IslandsEngine.Game.position_island(game, :player2, :dot, 1, 4)
    IslandsEngine.Game.position_island(game, :player2, :l_shape, 1, 5)
    IslandsEngine.Game.position_island(game, :player2, :s_shape, 5, 1)
    IslandsEngine.Game.position_island(game, :player2, :square, 5, 5)
    IslandsEngine.Game.set_islands(game, :player2)

    a = IslandsEngine.Game.guess_coordinate(game, :player1, 1, 1)
    assert {:hit, :none, :no_win} == a
  end

  test "start server" do
    via = IslandsEngine.Game.via_tuple("Foo8")
    GenServer.start_link(IslandsEngine.Game, "Foo8", name: via)
    {r, {s, _pid}} = GenServer.start_link(IslandsEngine.Game, "Foo8", name: via)
    assert r == :error
    assert s == :already_started
  end

  test "putting the peaces together" do
    {:ok, game} = IslandsEngine.GameSupervisor.start_game("Bar2")
    via = IslandsEngine.Game.via_tuple("Bar2")
    assert via == {:via, Registry, {Registry.Game, "Bar2"}}

    IslandsEngine.Game.add_player(via, "Foo")

    state_data = :sys.get_state(via)
    assert state_data.player1.name == "Bar2"
    assert state_data.player2.name == "Foo"

    true = Process.exit(game, :kaboom)

    # allow the game to be killed
    Process.sleep(500)

    state_data = :sys.get_state(via)
    assert state_data.player1.name == "Bar2"
    assert state_data.player2.name == "Foo"
  end

  test "terminate" do
    {:ok, game} = IslandsEngine.GameSupervisor.start_game("Paxton")
    via = IslandsEngine.Game.via_tuple("Paxton")
    alive = Process.alive?(game)
    assert alive == true
    IslandsEngine.GameSupervisor.stop_game("Paxton")
    pid = GenServer.whereis(via)
    assert pid == nil
    alive = Process.alive?(game)
    assert alive == false
    state = :ets.lookup(:game_state, "Paxton")
    assert state == []
  end
end
