defmodule PlayerSupervisorTest do
	use ExUnit.Case
	doctest PlayerSupervisor

	setup do
		Application.stop(GameServer)
		Application.start(GameServer)
		%{}
	end

	test "测试PlayerSupervisor启动PlayerServer" do
		player1 = Player.init |> Player.set_id(1)
		player2 = Player.init |> Player.set_id(2)
		assert {:ok, _p1} = PlayerSupervisor.start_player(player1)
		assert {:ok, _p2} = PlayerSupervisor.start_player(player2)
		assert PlayerServer.exist?(player1)
		assert PlayerServer.exist?(player2)
	end

end