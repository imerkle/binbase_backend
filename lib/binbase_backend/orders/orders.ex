defmodule BinbaseBackend.Orders do
  
  import Ecto.Query, warn: false
  def create_order(order) do
    {:ok, x} = BinbaseBackend.Repo.insert(order)
    BinbaseBackend.Engine.Broadcaster.broadcast("me msg")
    {:ok, x}
  end
end