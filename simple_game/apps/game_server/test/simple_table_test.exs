defmodule SimpleTableTest do
  use ExUnit.Case
  doctest SimpleTable
  import TestPlayer 

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

  describe "开局" do
    test "少于2个人的时候不能", %{table: table, player1: player1} do
         assert {:error, ErrorMsg.player_not_enough} == table |> SimpleTable.add_seat(player1) |> SimpleTable.start(player1)
    end

    test "非准备阶段不能", %{table: table, player1: player1} do
      assert {:error, ErrorMsg.not_ready_state} == table |> SimpleTable.open_state |> SimpleTable.start(player1)
    end

    test "准备阶段且人数至少2, 且只有房主能开局, 且已经发牌了", %{table: table, player1: player1, player2: player2} do
         table = table |> SimpleTable.set_creator(player1) 
                       |> SimpleTable.add_seat(player1) 
                       |> SimpleTable.add_seat(player2) 
        assert {:error, ErrorMsg.just_creator_can_start} == table |> SimpleTable.start(player2)
        assert {:ok, new_table} = table |> SimpleTable.start(player1)
        assert 2 = new_table |> SimpleTable.find_seat(player1) |> Seat.get_cards |> length
        assert new_table |> SimpleTable.open_state?
    end
  end

  describe "解散" do
    test "正在玩中不能", %{table: table, player1: player1} do
      assert {:error, ErrorMsg.can_not_dismiss_when_playing} == table |> SimpleTable.open_state |> SimpleTable.dismiss(player1)
    end

    test "解散：准备阶段只有房主可以", %{table: table, player1: player1, player2: player2} do
       table = table |> SimpleTable.set_creator(player1)
       assert {:error, ErrorMsg.just_creator_can_dismiss} == table |> SimpleTable.dismiss(player2)
       assert {:ok, new_table} = table |> SimpleTable.dismiss(player1) 
       assert new_table |> SimpleTable.dismiss_state?
    end 
  end

  describe "加入" do
    test "人数限制不能", %{table: table, player1: player1} do
      assert {:error, ErrorMsg.player_num_limit} == table |> SimpleTable.set_limit(0)  |> SimpleTable.join(player1)
    end

    test "正在玩中不能（以后支持？）", %{table: table, player1: player1} do
      assert {:error, ErrorMsg.can_not_join_when_playing} == table |> SimpleTable.open_state |> SimpleTable.join(player1)
    end

    test "准备阶段可以", %{table: table, player1: player1} do
      assert {:ok, new_table} = table |> SimpleTable.join(player1) 
      assert 1 = new_table |> SimpleTable.seat_count 
    end

    test "重复不可以", %{table: table, player1: player1} do
      assert {:error, ErrorMsg.repeated_join} == table |> SimpleTable.add_seat(player1) |> SimpleTable.join(player1)
    end
  end

  describe "退出" do
    test "正在玩中不能（以后支持？）", %{table: table, player1: player1} do
      assert {:error, ErrorMsg.can_not_quit_when_playing} == table |> SimpleTable.open_state |> SimpleTable.quit(player1)
    end

    test "房主不能（以后支持？)", %{table: table, player1: player1} do
      assert {:error, ErrorMsg.can_not_quit_when_creator} == table |> SimpleTable.set_creator(player1) |> SimpleTable.quit(player1)
    end

    test "非玩中， 非房主可以退出", %{table: table, player1: player1, player2: player2} do
      assert {:ok, new_table} = table |> SimpleTable.set_creator(player1) 
                                      |> SimpleTable.add_seat(player1) 
                                      |> SimpleTable.add_seat(player2) 
                                      |> SimpleTable.quit(player2)
      assert 1 = new_table |> SimpleTable.seat_count
    end
  end

  test "测试发牌", %{table: table, player1: player1, player2: player2} do
      cards = [{1, 1}, {1, 2}, {1, 3}, {1, 4}, {1, 5}, {1, 6}]
      table = table |> SimpleTable.set_cards(cards)
                    |> SimpleTable.add_seat(player1)
                    |> SimpleTable.add_seat(player2)
                    |> SimpleTable.deal
      assert [{1, 1}, {1, 2}] == table |> SimpleTable.find_seat(player1) |> Seat.get_cards
      assert [{1, 3}, {1, 4}] == table |> SimpleTable.find_seat(player2) |> Seat.get_cards
  end

  describe "补牌" do
    test "非补牌阶段不能", %{table: table, player1: player1} do
       assert {:error, ErrorMsg.not_makeup_state} == table |> SimpleTable.make_up(player1)
    end

    test "已经翻牌操作了不能", %{table: table, player1: player1} do
       seat = Seat.init(player1) |> Seat.open
       assert {:error, ErrorMsg.can_not_make_up_when_open} == table |> SimpleTable.update_seat(seat)
                                                        |> SimpleTable.makeup_state
                                                        |> SimpleTable.make_up(player1)
    end

    test "已经补牌操作了不能", %{table: table, player1: player1} do
       seat = Seat.init(player1) |> Seat.make_up
       assert {:error, ErrorMsg.makeup_op_done} == table |> SimpleTable.update_seat(seat)
                                                        |> SimpleTable.makeup_state
                                                        |> SimpleTable.make_up(player1)
      
    end





    test "正在游戏中，未翻牌操作，尚未补牌则可补牌", %{table: table, player1: player1} do
       seat = Seat.init(player1) |> Seat.add_cards([1,2])
       assert {:ok, new_table} = table |> SimpleTable.add_seat(player1)
                                        |> SimpleTable.update_seat(seat)
                                        |> SimpleTable.makeup_state
                                        |> SimpleTable.set_cards([3,4])
                                        |> SimpleTable.make_up(player1)
      assert new_table |> SimpleTable.find_seat(player1) |> Seat.is_makeup?
    end

    test "所有人补牌操作了，进入结算阶段", %{table: table, player1: player1} do
       seat = Seat.init(player1) 
       assert {:ok, new_table} = table |> SimpleTable.add_seat(player1)
                                        |> SimpleTable.update_seat(seat)
                                        |> SimpleTable.makeup_state
                                        |> SimpleTable.not_make_up(player1)
       assert SimpleTable.settle_state?(new_table)
      
    end

  end


  describe "翻牌与不翻牌" do

    test "非翻牌阶段不能翻牌", %{table: table, player1: player1} do
       assert {:error, ErrorMsg.not_open_state} == table |> SimpleTable.open(player1)
       assert {:error, ErrorMsg.not_open_state} == table |> SimpleTable.not_open(player1)
    end


    test "不是天公牌不能", %{table: table, player1: player1} do
      seat = Seat.init(player1) |> Seat.add_cards([{1, 2}, {1, 5}])
      assert {:error, ErrorMsg.just_tian_gong_can_open} == table |> SimpleTable.open_state 
                                                                |> SimpleTable.update_seat(seat) 
                                                                |> SimpleTable.open(player1)
    end

    test "已经操作过了不能", %{table: table, player1: player1} do
      seat = Seat.init(player1) |> Seat.open
      assert {:error, ErrorMsg.open_op_done} == table |> SimpleTable.open_state 
                                                        |> SimpleTable.update_seat(seat) 
                                                        |> SimpleTable.open(player1)
    end

    test "游戏中, 不翻牌", %{table: table, player1: player1} do
      seat = Seat.init(player1) |> Seat.add_cards([{1,2}, {1, 7}])
      assert {:ok, new_table} = table |> SimpleTable.add_seat(player1) 
                                        |> SimpleTable.update_seat(seat)
                                        |> SimpleTable.open_state 
                                        |> SimpleTable.open(player1)    
      seat = SimpleTable.find_seat(new_table, player1)
      assert Seat.is_open?(seat)
      assert Seat.open_op_done?(seat)
    end

    test "游戏中，天公翻牌", %{table: table, player1: player1} do
       seat = Seat.init(player1) |> Seat.add_cards([{1, 2}, {1, 7}])
       assert {:ok, new_table} = table |> SimpleTable.add_seat(player1) 
                                        |> SimpleTable.update_seat(seat)
                                        |> SimpleTable.open_state 
                                        |> SimpleTable.open(player1)    
      seat = SimpleTable.find_seat(new_table, player1)
      assert Seat.is_open?(seat)
      assert Seat.open_op_done?(seat)
    end

    test "所有人翻牌操作了进入补牌阶段", %{table: table, player1: player1, player2: player2} do
       seat = Seat.init(player1) 
       assert {:ok, new_table} = table |> SimpleTable.add_seat(player1)
                                       |> SimpleTable.update_seat(seat)
                                       |> SimpleTable.open_state
                                       |> SimpleTable.not_open(player1)
       assert SimpleTable.makeup_state?(new_table)
    end
  end



end