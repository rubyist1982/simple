defmodule Seat do
	def init(player) do
		%{
			id: player |> Player.get_id,
			player: player,
			score: 0,
			cards: [],
			open_op: nil,    # nil 标识未操作， true 翻牌， false 补牌
			makeup_op: nil 

		}
	end

	def get_id(seat), do: seat.id
	
	def update_player(seat, player), do: put_in(seat.player, player)
	def get_player(seat), do: seat.player
	def get_player_id(seat), do: seat.player |> Player.get_id

	def add_score(seat, num) when num >=0 , do: update_in(seat.score, &(&1 + num))
	def sub_score(seat, num) when num >= 0 , do: update_in(seat.score, &(&1 - num))
	def get_score(seat), do: seat.score
	def reset_score(seat), do: put_in(seat.score, 0)


	def get_cards(seat), do: seat.cards
	def add_cards(seat, cards) when is_list(cards), do: put_in(seat.cards, cards)
	def add_cards(seat, a_card), do: update_in(seat.cards, fn old -> old ++ [a_card] end)
	def reset_cards(seat), do: put_in(seat.cards, [])

	def open(seat), do: put_in(seat.open_op, true)
	def not_open(seat), do: put_in(seat.open_op, false)
	def is_open?(seat), do: seat.open_op 
	def open_op_done?(seat), do: seat.open_op != nil
	def reset_open_op(seat), do: put_in(seat.open_op, nil)

	def is_makeup?(seat), do: seat.makeup_op
	def make_up(seat), do: put_in(seat.makeup_op, true)
	def not_make_up(seat), do: put_in(seat.makeup_op, false)
	def reset_makeup_op(seat), do: put_in(seat.makeup_op, nil)
	def makeup_op_done?(seat), do: seat.makeup_op != nil

	def reset(seat) do
		seat |> reset_score |> reset_cards |> reset_open_op |> reset_makeup_op
	end
end