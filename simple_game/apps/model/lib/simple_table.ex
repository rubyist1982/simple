defmodule SimpleTable do
	
	def init() do
		%{
			cards: SimplePoker.init_cards,
			creator: nil,
			seat_map: %{},
			seat_order: []
		}
	end

	def seat_count(table), do: table.seat_order |> Enum.count
	def seat_order(table), do: table.seat_order

	def find_seat(table, %{} = player), do: find_seat(table, player |> Player.get_id)
	def find_seat(table, player_id), do: table.seat_map[player_id]

	def add_seat(table, player) do
		seat = Seat.init(player)
		seat_id = seat |> Seat.get_id
		table = put_in(table.seat_map[seat_id], seat)
		add_to_order(table, seat_id)
	end

	def add_to_order(table, seat_id), do: update_in(table.seat_order, &(&1 ++ [seat_id]))

	def remove_seat(table, %{} = player), do: remove_seat(table, player |> Player.get_id)
	def remove_seat(table, player_id) do
		table = update_in(table.seat_map, fn m -> Map.delete(m, player_id) end)
		update_in(table.seat_order, fn o -> List.delete(o, player_id) end)
	end

	
end