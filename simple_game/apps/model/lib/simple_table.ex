defmodule SimpleTable do
	@state_ready  :ready
	@state_playing :playing
	@state_dismiss :dismiss
	def init() do
		%{
			id: 0,
			cards: nil,
			creator: nil,
			seat_map: %{},
			seat_order: [],
			state: @state_ready
		}
	end

	def is_playing?(table), do: table.state == @state_playing
	def is_dismiss?(table), do: table.state == @state_dismiss
	def is_ready?(table), do: table.state == @state_ready

	def set_playing(table), do: put_in(table.state, @state_playing)
	def set_ready(table), do: put_in(table.state, @state_ready)
	def set_dismiss(table), do: put_in(table.state, @state_dismiss)


	def set_cards(table, cards), do: put_in(table.cards, cards)
	def get_cards(table), do: table.cards

	def init_deal(table) do
		table.seat_order
		|> Enum.map(&(find_seat(table, &1)))
		|> Enum.reduce(table, 
			fn seat, new_table ->
				new_table |> init_deal_one(seat)
			end)
	end

	def init_deal_one(table, seat) do
		{:ok, cards, left} = SimplePoker.init_deal(table.cards)
		seat = seat |> Seat.add_cards(cards)
		table |> update_seat(seat)
			  |> set_cards(left)
	end

	def set_id(table, id), do: put_in(table.id, id)
	def get_id(table), do: table.id

	def set_creator(table, player), do: put_in(table.creator, player)
	def get_creator(table), do: table.creator
	
	def seat_count(table), do: table.seat_order |> Enum.count
	def seat_order(table), do: table.seat_order

	def find_seat(table, %{} = player), do: find_seat(table, player |> Player.get_id)
	def find_seat(table, player_id), do: table.seat_map[player_id]


	def add_seat(table, player) do
		seat = Seat.init(player)
		seat_id = seat |> Seat.get_id
		table = table |> update_seat(seat)
		add_to_order(table, seat_id)
	end

	def update_seat(table, seat), do: put_in(table.seat_map[seat |> Seat.get_id], seat)

	def add_to_order(table, seat_id), do: update_in(table.seat_order, &(&1 ++ [seat_id]))

	def remove_seat(table, %{} = player), do: remove_seat(table, player |> Player.get_id)
	def remove_seat(table, player_id) do
		table = update_in(table.seat_map, fn m -> Map.delete(m, player_id) end)
		update_in(table.seat_order, fn o -> List.delete(o, player_id) end)
	end

	def start(table, player) do
		cond do
			is_playing?(table) -> {:error, ErrorMsg.can_not_start_when_playing}
			seat_count(table) < 2 -> {:error, ErrorMsg.player_not_enough}
			not is_creator?(table, player) -> {:error, ErrorMsg.just_creator_can_start}
			true ->
				table = table |> set_playing
				{:ok, table}
		end
	end

	def quit(table, player) do
		cond do
			is_playing?(table) -> {:error, ErrorMsg.can_not_quit_when_playing}
			is_creator?(table, player) -> {:error, ErrorMsg.can_not_quit_when_creator}
		end
	end
	
	def dismiss(table, player) do
		cond do
			is_playing?(table) -> {:error, ErrorMsg.can_not_dismiss_when_playing}
			not is_creator?(table, player) -> {:error, ErrorMsg.just_creator_can_dismiss}
			true ->
				table = table |> set_dismiss
				{:ok, table}
		end
	end

	def make_up(table, player) do
		cond do
			is_ready?(table) -> {:error, ErrorMsg.can_not_make_up_when_not_playing}
			find_seat(table, player) |> Seat.is_open? -> {:error, ErrorMsg.can_not_make_up_when_open}
			find_seat(table, player) |> Seat.is_full? -> {:error, ErrorMsg.can_not_make_up_when_full}
		end
	end

	def join(table, player) do
		cond do
			is_playing?(table) -> {:error, ErrorMsg.can_not_join_when_playing}
			find_seat(table, player) -> {:error, ErrorMsg.repeated_join}
			true -> 
				table = table |> add_seat(player)
				{:ok, table}
		end
	end

	def open(table, player) do
		cond do
			find_seat(table, player) |> Seat.is_open? -> {:error, ErrorMsg.repeated_open}
			not (find_seat(table, player) |> Seat.get_cards |> SimplePoker.can_be_tian_gong?) -> {:error, ErrorMsg.just_tian_gong_can_open}
		end
	end


	def is_creator?(table, player), do: table.creator |> Player.get_id == player |> Player.get_id

end