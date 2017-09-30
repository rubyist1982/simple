defmodule PlayerServer do
	use GenServer, restart: :temporary, start: {__MODULE__, :start_link, []}

	def start_link(player) do
    	GenServer.start_link(__MODULE__, player, name: __MODULE__)
  	end

	def init(player) do
		{:ok, player}
	end
end