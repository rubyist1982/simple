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
 
end
