defmodule Seat do
	def init(player) do
		%{
			id: player |> Player.get_id,
			player: player,
			score: 0,
		}
	end

	def get_id(seat), do: seat.id
	
	def update_player(seat, player), do: put_in(seat.player, player)
	def get_player(seat), do: seat.player
	def get_player_id(seat), do: seat.player |> Player.get_id

	def add_score(seat, num) when num >=0 , do: update_in(seat.score, &(&1 + num))
	def sub_score(seat, num) when num >= 0 , do: update_in(seat.score, &(&1 - num))
	def get_score(seat), do: seat.score

end