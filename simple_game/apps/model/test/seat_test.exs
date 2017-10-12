defmodule SeatTest do
  use ExUnit.Case
  doctest Seat
  
  setup do

    %{seat: Seat.init(Player.init)}
  end

  test "init", %{seat: seat} do
    assert 0 == seat |> Seat.get_score
  end

  test "add_and_remove_score", %{seat: seat} do
    num = 10
    old_score = seat |> Seat.get_score
    add_score_seat = seat |> Seat.add_score(num) 
    assert old_score + num == add_score_seat |> Seat.get_score
    sub_score_seat = seat |> Seat.sub_score(num)
    assert old_score - num == sub_score_seat |> Seat.get_score
  end

  test "添加牌", %{seat: seat} do
      seat = seat |> Seat.add_cards([{1, 1}, {1, 2}]) |> Seat.add_cards({1,3})
      assert [{1, 1}, {1, 2}, {1, 3}] == seat |> Seat.get_cards
  end

  test "公开牌", %{seat: seat} do
      seat = seat |> Seat.open
      assert Seat.is_open?(seat)
  end

  test "重置", %{seat: seat} do
     seat = seat |> Seat.add_score(10)
                  |> Seat.add_cards({1,1})
                  |> Seat.open
                  |> Seat.reset
      assert 0 == seat |> Seat.get_score
      assert [] == seat |> Seat.get_cards
      refute seat |> Seat.is_open?

  end
 
end
