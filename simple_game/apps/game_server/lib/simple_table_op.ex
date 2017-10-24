defmodule SimpleTableOp do
	use PlayerUtil
	defmacro __using__(_opts) do
		quote do
			import unquote(__MODULE__)
		end
	end


	

	def create(player), do: call(player, {:create_table})

	def join(player, table), do: call(player, {:table_join, table})

	def quit(player, table), do: call(player, {:table_quit, table})

	def open(player, table), do: call(player, {:table_open, table})

	def not_open(player, table), do: call(player, {:table_not_open, table})

	def makeup(player, table), do: call(player, {:table_makeup, table})
    
    def not_makeup(player, table), do: call(player, {:player, table})

    def dismiss(player, table), do: call(player, {:player, table})


    def handle({:create_table}, _from, player) do
    	ok(player)
    end

   
end