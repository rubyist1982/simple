defmodule TableServerTest do
	use ExUnit.Case
	doctest TableServer
	import TestPlayer

	setup do
		Application.stop(:game_server)
		Application.start(:game_server)
		%{

		}
	end

	test "创建桌子进程" do
		assert {:ok, _table} = TableServer.create(create_player(1))
	end



end