defmodule PlayerServer do
	use GenServer, restart: :temporary, start: {__MODULE__, :start_link, []}

	def start_link(player) do
    	GenServer.start_link(__MODULE__, player, name: register_name(player))
  	end

	def init(player) do
		{:ok, player}
	end

	def register_name(%{} = player), do: register_name(player |> Player.get_id)
	def register_name(id), do: {:via, Registry, {LocalRegistry, {Player, id}}}

	def whereis(%{} = player), do: whereis(player |> Player.get_id)
	def whereis(player_id) do
		key = {Player, player_id}
		case Registry.lookup(LocalRegistry, key) do
			[{pid, _}] -> pid
			[] -> :undefined
		end
	end
		
	def exist?(player) do
		case whereis(player) do
			:undefined -> false
			_ -> true
		end
	end


	def handle_call({module, request}, from, player) do
		case apply(module, :handle, [request, from, player]) do
	    	{:error, _} = error ->
	    		{:reply, error, player}
	    	{result, new_player} ->
	    		{:reply, result, new_player}
	    end
	end




end 