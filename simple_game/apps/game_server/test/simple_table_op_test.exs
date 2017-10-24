defmodule SimpleTableOpTest do
  use ExUnit.Case
  import TestPlayer 

  setup do
  	Application.stop(:game_server)
  	Application.start(:game_server)
    {:ok, player_pid } = PlayerSupervisor.start_player(create_player(1))
  	%{
  		player_pid: player_pid 
  	}
  end

  test "create", %{player_pid: player_pid} do
  	  assert :ok = SimpleTableOp.create(player_pid)
  end
end