defmodule TableSupervisorTest do
	use ExUnit.Case
	doctest PlayerSupervisor

	setup do
		Application.stop(GameServer)
		Application.start(GameServer)
		%{}
	end

	test "测试TableSupervisor启动TableServer" do
		table1 = SimpleTable.init |> SimpleTable.set_id(1)
		table2 = SimpleTable.init |> SimpleTable.set_id(2)
		assert {:ok, _p1} = TableSupervisor.start_table(table1)
		assert {:ok, _p2} = TableSupervisor.start_table(table2)
		assert TableServer.exist?(table1)
		assert TableServer.exist?(table2)
	end
end