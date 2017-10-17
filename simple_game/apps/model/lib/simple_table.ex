defmodule SimpleTable do
	@state_ready  :state_ready # 准备
	@state_open :state_open # 天公翻牌
	@state_makeup :state_makeup # 补牌
	@state_settle :state_settle # 结算
	@state_dismiss :dismiss    # 解散

	@limit 17   # 最多17人玩
	@timeout  10 # 翻牌、补牌超时, 10s

	def init() do
		%{
			id: 0,
			cards: nil,
			creator: nil,
			seat_map: %{},
			seat_order: [],
			state: @state_ready,
			limit: @limit
		}
	end

	def set_limit(table, limit), do: put_in(table.limit, limit)

	def ready_state(table), do: put_in(table.state, @state_ready)
	def ready_state?(table), do: table.state == @state_ready

	def open_state(table), do: put_in(table.state, @state_open)
	def open_state?(table), do: table.state == @state_open

	def makeup_state(table), do: put_in(table.state, @state_makeup)
	def makeup_state?(table), do: table.state == @state_makeup

	def settle_state(table), do: put_in(table.state, @state_settle)
	def settle_state?(table), do: table.state == @state_settle

	def dismiss_state(table), do: put_in(table.state, @state_dismiss)
	def dismiss_state?(table), do: table.state == @state_dismiss


	def set_cards(table, cards), do: put_in(table.cards, cards)
	def get_cards(table), do: table.cards

	def deal(table) do
		table.seat_order
		|> Enum.map(&(find_seat(table, &1)))
		|> Enum.reduce(table, 
			fn seat, new_table ->
				new_table |> deal(seat, 2)
			end)
	end

	def deal_player(table, player, num) do
		seat = find_seat(table, player)
		deal(table, seat, num)
	end
	def deal(table, seat, num) do
		{:ok, cards, left} = SimplePoker.deal(table.cards, num)
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

	def in_table?(table, player) do
		if find_seat(table, player), do: true , else: false
	end
	def find_seat(table, %{} = player), do: find_seat(table, player |> Player.get_id)
	def find_seat(table, player_id), do: table.seat_map[player_id]

	def get_seats(table), do: table.seat_map |> Enum.to_list

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
			not ready_state?(table) -> {:error, ErrorMsg.not_ready_state}
			seat_count(table) < 2 -> {:error, ErrorMsg.player_not_enough}
			not is_creator?(table, player) -> {:error, ErrorMsg.just_creator_can_start}
			true ->
				cards = SimplePoker.init_cards |> SimplePoker.shuffle
				table = table |> open_state
							  |> set_cards(cards)
							  |> deal
				{:ok, table}
		end
	end

	def quit(table, player) do
		cond do
			not ready_state?(table) -> {:error, ErrorMsg.can_not_quit_when_playing}
			is_creator?(table, player) -> {:error, ErrorMsg.can_not_quit_when_creator}
			not in_table?(table, player) -> {:error, ErrorMsg.not_in_table}	
			true ->
				table = table |> remove_seat(player)
				{:ok, table}
		end
	end
	
	def dismiss(table, player) do
		cond do
			not ready_state?(table) -> {:error, ErrorMsg.can_not_dismiss_when_playing}
			not is_creator?(table, player) -> {:error, ErrorMsg.just_creator_can_dismiss}
			true ->
				table = table |> dismiss_state
				{:ok, table}
		end
	end

	def make_up(table, player) do
		cond do
			not makeup_state?(table) -> {:error, ErrorMsg.not_makeup_state}
			find_seat(table, player) |> Seat.is_open? -> {:error, ErrorMsg.can_not_make_up_when_open}
			find_seat(table, player) |> Seat.is_full? -> {:error, ErrorMsg.can_not_make_up_when_full}
			true ->
				table = table |> deal_player(player, 1)
				{:ok, table}
		end
	end

	def reach_limit?(table), do: seat_count(table) >= table.limit

	def join(table, player) do
		cond do
			not ready_state?(table) -> {:error, ErrorMsg.can_not_join_when_playing}
			reach_limit?(table) -> {:error, ErrorMsg.player_num_limit}
			find_seat(table, player) -> {:error, ErrorMsg.repeated_join}
			true -> 
				table = table |> add_seat(player)
				{:ok, table}
		end
	end

	def open(table, player) do
		cond do
			not open_state?(table) -> {:error, ErrorMsg.not_open_state}
			find_seat(table, player) |> Seat.is_open? -> {:error, ErrorMsg.repeated_open}
			not (find_seat(table, player) |> Seat.get_cards |> SimplePoker.can_be_tian_gong?) -> {:error, ErrorMsg.just_tian_gong_can_open}
			true ->
				seat = find_seat(table, player) |> Seat.open
				table = table |> update_seat(seat)
				{:ok, table}
		end
	end


	def is_creator?(table, player), do: table.creator |> Player.get_id == player |> Player.get_id

end