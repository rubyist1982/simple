defmodule TestPlayer do
	 def create_player(id), do: Player.init |> Player.set_id(id)
end
ExUnit.start()
