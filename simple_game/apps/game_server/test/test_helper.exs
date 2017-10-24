defmodule TestPlayer do
	 import ExUnit.Assertions	
	 def create_player(id), do: Player.init |> Player.set_id(id)
	def call_ok?(:ok), do: assert true
	def call_ok?({:error, _any}), do: assert true
	def call_ok?(_), do: assert false

end
ExUnit.start()
