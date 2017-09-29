defmodule Player do
	def init do
		%{
			id: 0,     # 唯一标识
			name: "",   # 昵称
			gold: 0,     # 金币
		}
	end

	def get_id(player), do: player.id
	def set_id(player, new_id), do: put_in(player.id, new_id)

	def set_name(player, new_name), do: put_in(player.name, new_name)
	def get_name(player), do: player.name


	def add(num) when num >=0 , do: &(&1 + num)
	def cost(num) when num >=0 , do: &(&1 - num)

	def get_gold(player), do: player.gold
	def add_gold(player, num) , do: update_in(player.gold, add(num))
	def cost_gold(player, num), do: update_in(player.gold, cost(num))
end