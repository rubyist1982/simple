defmodule PlayerTest do
  use ExUnit.Case
  doctest Player
  
  setup do

    %{player: Player.init}
  end

  test "设置ID", %{player: player} do
  	set_id = "test"
  	new_id = player |> Player.set_id(set_id) |> Player.get_id
  	assert new_id == set_id
  end

  test "设置昵称", %{player: player} do
  	set_name = "新名字"
  	new_name= player |> Player.set_name(set_name) |> Player.get_name
  	assert new_name == set_name
  end

  test "增加金币", %{player: player} do
  	num = 10
    new_gold =  player |> Player.add_gold(num) |> Player.get_gold
    old_gold = player |> Player.get_gold
    assert new_gold == old_gold + num
  end

  test "减少金币", %{player: player} do
  	num = 10
  	new_gold = player |> Player.cost_gold(num) |> Player.get_gold
  	old_gold = player |> Player.get_gold
  	assert new_gold == old_gold - num
  end
end
