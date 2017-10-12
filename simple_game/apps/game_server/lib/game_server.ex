defmodule GameServer do
  use Application
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: LocalRegistry},
      PlayerSupervisor,
      TableSupervisor
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
