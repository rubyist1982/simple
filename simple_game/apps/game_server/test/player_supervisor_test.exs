defmodule PlayerSupervisorTest do
	use ExUnit.Case
	doctest PlayerSupervisor

	setup do
		Application.stop(GameServer)
		Application.start(GameServer)
		%{}
	end

	test "测试PlayerSupervisor启动PlayerServer" do
		assert {:ok, p1} = PlayerSupervisor.start_player(Player.init |> Player.set_id(1))
		assert {:ok, p2} = PlayerSupervisor.start_player(Player.init |> Player.set_id(2))
		assert [{^p1, nil}] = Registry.lookup(PlayerRegistry, 1)
		assert [{^p2, nil}] = Registry.lookup(PlayerRegistry, 2)
	end

end