defmodule TableSupervisor do
	use Supervisor

	def start_link(_opts) do
    	Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  	end

	def init(:ok) do
	    Supervisor.init([TableServer], strategy: :simple_one_for_one)
	end

	def start_table(table) do
		Supervisor.start_child(__MODULE__, [table])		
	end
end