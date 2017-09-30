defmodule PlayerServer do
	use GenServer, restart: :temporary, start: {__MODULE__, :start_link, []}

	def start_link(player) do
    	GenServer.start_link(__MODULE__, player, name: register_name(player))
  	end

	def init(player) do
		{:ok, player}
	end

	def register_name(%{} = player), do: register_name(player |> Player.get_id)
	def register_name(id), do: {:via, Registry, {PlayerRegistry, id}}
end