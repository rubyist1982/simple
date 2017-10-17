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

	def create(player) do
		table = SimpleTable.init 
				|> SimpleTable.set_id(player |> Player.get_id)
				|> SimpleTable.set_creator(player)
				|> SimpleTable.add_seat(player)
		{:ok, _pid} = TableSupervisor.start_table(table)
		{:ok, table}
	end

	def call(table, request, timeout \\ 1000), do: GenServer.call(table, request, timeout)

	def join(table, player), do: call(table, {:join, player: player})

	def quit(table, player), do: call(table, {:quit, player: player})

	def dismiss(table, player), do: call(table, {:dismiss, player: player})

	def start(table, player), do: call(table, {:start, player: player})

	def open(table, player), do: call(table, {:open, player: player})

	def makeup(table, player), do: call(table, {:makeup, player: player})

    def handle_call(request, from, table) do
	    case inner_handle_call(request, from, table) do
	    	{:error, _} = error ->
	    		{:reply, error, table}
	    	{result, new_table} ->
	    		{:reply, result, new_table}
	    end
    end



    def ok(table), do: {:ok, table}
    def ok(result, table), do: {{:ok, result}, table}


    def inner_handle_call({:join, player: player}, _from, table) do 
    	with {:ok, table}  <- table |> SimpleTable.join(player)
    	do
    		seat = SimpleTable.find_seat(table, player)
    		broadcast_join(table, seat)
    		ok(table, table)
    	else
    		error -> error
    	end
    end

    def inner_handle_call({:quit, player: player}, _from, table) do
    	with {:ok, table} <- table |> SimpleTable.quit(player)
    	do
    		broadcast_quit(table, player)
    		ok(table)
    	else
    		error -> error
    	end
   	end

    def inner_handle_call({:dismiss, player: player}, _from, table) do
    	with {:ok, table} <- table |> SimpleTable.dismiss(player)
    	do
    		broadcast_dismiss(table)
    		ok(table)
		else
			error -> error
    	end
    end

    def inner_handle_call({:start, player: player}, _from, table) do
    	with {:ok, table} <- table |> SimpleTable.start(player)
		do
			broadcast_start(table)
			ok(table)
		else
			error -> error
		end
    end

    def inner_handle_call({:open, player: player}, _from, table) do
    	with {:ok, table} <- table |> SimpleTable.open(player)
    	do
    		broadcast_open(table, player)
    		ok(table)
    	else
    		error -> error
    	end
    	{:ok, table}
    end

    def inner_handle_call({:makeup, player: player}, _from, table) do
    	with {:ok, table} <- table |> SimpleTable.make_up(player)
    	do
    		broadcast_makeup(table, player)
    		ok(table)
    	else
    		error -> error
    	end
    end

    def broadcast_join(_table, _seat) do
    	
    end

    def broadcast_quit(_table, _player) do
    	
    end

    def broadcast_dismiss(_table) do
    	
    end

    def broadcast_start(_table) do
    	
    end

    def broadcast_open(_table, _player) do
    	
    end

    def broadcast_makeup(_table, _player) do
    	
    end

end