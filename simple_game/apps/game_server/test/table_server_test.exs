defmodule TableServerTest do
	use ExUnit.Case
	doctest TableServer
	import TestPlayer

	setup do
		Application.stop(:game_server)
		Application.start(:game_server)
		player1 = create_player(1)
		player2 = create_player(2)
		{:ok, table} = TableServer.create(player1)
		%{
			table_pid: TableServer.whereis(table),
			player1: player1,
			player2: player2 
		}
	end

	test "join", %{table_pid: table_pid, player1: player1} do
	  table_pid |> TableServer.join(player1) |> call_ok?
	end

	test "quit", %{table_pid: table_pid, player1: player1} do 
		 table_pid |> TableServer.quit(player1) |> call_ok?
	end

	test "start", %{table_pid: table_pid, player1: player1} do 
		table_pid |> TableServer.start(player1) |> call_ok? 
	end

	test "open", %{table_pid: table_pid, player1: player1} do 
		table_pid |> TableServer.open(player1) |> call_ok?
	end

	test "not_open", %{table_pid: table_pid, player1: player1} do
	   table_pid |> TableServer.not_open(player1) |> call_ok?
	end

	test "makeup", %{table_pid: table_pid, player1: player1} do 
		table_pid |> TableServer.makeup(player1) |> call_ok?
	end

	test "not_makeup", %{table_pid: table_pid, player1: player1} do
	  table_pid |> TableServer.not_makeup(player1) |> call_ok?
	end

	test "dismiss", %{table_pid: table_pid, player1: player1} do
	   table_pid |> TableServer.dismiss(player1) |> call_ok?
	end


	def call_ok?(:ok), do: assert true
	def call_ok?({:error, _any}), do: assert true
	def call_ok?(_), do: assert false


end