defmodule Seat do
	def init(player) do
		%{
			id: player |> Player.get_id,
			player: player,
			score: 0,
			cards: [],
			is_open: false

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

	def open(seat), do: put_in(seat.is_open, true)
	def is_open?(seat), do: seat.is_open
	def reset_is_open(seat), do: put_in(seat.is_open, false)

	def is_full?(seat), do: length(seat.cards) == 3

	def reset(seat) do
		seat |> reset_score |> reset_cards |> reset_is_open
	end
end