defmodule SimpleTableTest do
  use ExUnit.Case
  doctest SimpleTable
  
  def create_player(id), do: Player.init |> Player.set_id(id)

  setup do
    %{
    	table: SimpleTable.init,
  		player1: create_player(1),
  		player2: create_player(2),
  		player3: create_player(3),
  		player4: create_player(4),
    }
  end

  test "init", %{table: table} do
  	assert 0 = table |> SimpleTable.seat_count
  end

  test "add_and_remove_seat", %{table: table, player1: player1, player2: player2, player3: player3, player4: player4} do
  	  table = table |> SimpleTable.add_seat(player1) 
  	  				|> SimpleTable.add_seat(player2)
  	  				|> SimpleTable.add_seat(player3)
  	  				|> SimpleTable.add_seat(player4)

  	  assert 4 == SimpleTable.seat_count(table)
  	  expect_seat_order = [player1 |> Player.get_id,
  	          player2 |> Player.get_id,
  	      	  player3 |> Player.get_id,
  	      	  player4 |> Player.get_id]
  	  assert ^expect_seat_order = SimpleTable.seat_order(table)

  	  new_expect_seat_order = [
  	          player2 |> Player.get_id,
  	      	  player3 |> Player.get_id,
  	      	  player4 |> Player.get_id
  	      	]

  	  table = table |> SimpleTable.remove_seat(player1)
      assert 3 == SimpleTable.seat_count(table)
      assert ^new_expect_seat_order = SimpleTable.seat_order(table)
  end 

end