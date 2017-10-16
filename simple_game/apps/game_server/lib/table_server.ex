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
		TableSupervisor.start_table(table)
	end

	def join(table, player), do: GenServer.cast(table, {:join, player: player})

	def quit(table, player), do: GenServer.cast(table, {:quit, player: player})

	def dismiss(table, player), do: GenServer.cast(table, {:dismiss, player: player})

	def start(table, player), do: GenServer.cast(table, {:start, player: player})

	def open(table, player), do: GenServer.cast(table, {:open, player: player})

	def makeup(table, player), do: GenServer.cast(table, {:makeup, player: player})

    def handle_cast(request, table) do
	    {:ok, table} = inner_handle_cast(request, table) 
    	{:noreply, table}
    end



    def send_error(_player, _error) do
    
    end

  

    def inner_handle_cast({:join, player: player}, table) do 
    	with {:ok, table}  <- table |> SimpleTable.join(player)
    	do
    		seat = SimpleTable.find_seat(table, player)
    		broadcast_join(table, seat)
    	else
    		{:error, error} ->
    			send_error(player, error)
    	end
    	{:ok, table}
    end

    def inner_handle_cast({:quit, player: player}, table) do
    	with {:ok, table} <- table |> SimpleTable.quit(player)
    	do
    		broadcast_quit(table, player)
    	else
    		{:error, error} ->
    			send_error(player, error)
    	end
    	{:ok, table}
   	end

    def inner_handle_cast({:dismiss, player: player}, table) do
    	with {:ok, table} <- table |> SimpleTable.dismiss(player)
    	do
    		broadcast_dismiss(table)
		else
			{:error, error} ->
				send_error(player, error)
    	end
    	{:ok, table}
    end

    def inner_handle_cast({:start, player: player}, table) do
    	with {:ok, table} <-	table |> SimpleTable.start(player)
		do
			broadcast_start(table)
		else
			{:error, error} ->
				send_error(player, error)
		end
		{:ok, table}
    end

    def inner_handle_cast({:open, player: player}, table) do
    	with {:ok, table} <- table |> SimpleTable.open(player)
    	do
    		send_open(table, player)
    	else
    		{:error, error} ->
    			send_error(player, error)
    	end
    	{:ok, table}
    end

    def inner_handle_cast({:makeup, player: player}, table) do
    	with {:ok, table} <- table |> SimpleTable.make_up(player)
    	do
    		send_makeup(table, player)
    	else
    		{:error, error} ->
    			send_error(player, error)
    	end
    	{:ok, table}
    end

    def broadcast_join(_table, _seat) do
    	
    end

    def broadcast_quit(_table, _player) do
    	
    end

    def broadcast_dismiss(_table) do
    	
    end

    def broadcast_start(_table) do
    	
    end

    def send_open(_table, _player) do
    	
    end

    def send_makeup(_table, _player) do
    	
    end

end