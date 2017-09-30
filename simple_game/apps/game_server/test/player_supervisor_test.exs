defmodule PlayerSupervisorTest do
	use ExUnit.Case
	doctest PlayerSupervisor

	setup do
		start_supervised PlayerSupervisor
		%{}
	end

	test "测试PlayerSupervisor启动PlayerServer" do
		assert {:ok, _player_pid} = PlayerSupervisor.start_player(Player.init)
	end
end