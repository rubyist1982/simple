defmodule TableServer do
	use GenServer, restart: :temporary, start: {__MODULE__, :start_link, []}

	def start_link(table) do
    	GenServer.start_link(__MODULE__, table, name: register_name(table))
  	end

	def init(table) do
		{:ok, table}
	end

	def register_name(%{} = table), do: register_name(table |> SimpleTable.get_id)
	def register_name(id), do: {:via, Registry, {LocalRegistry, {Table, id}}}

	def exist?(table) do
		key = {Table, table |> SimpleTable.get_id}
		case Registry.lookup(LocalRegistry, key) do
			[{_pid, _}] -> true
			[] -> false
		end
	end

end