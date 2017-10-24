defmodule PlayerUtil do
	defmacro __using__(_opts) do
		quote do
			import unquote(__MODULE__)
			def call(player, request, timeout \\ 1000) do
				 GenServer.call(player, {__MODULE__, request}, timeout)
			end
		end
	end

    def ok(player), do: {:ok, player}
    def ok(result, player), do: {{:ok, result}, player}

end