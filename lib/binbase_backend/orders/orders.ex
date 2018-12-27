defmodule BinbaseBackend.Orders do
  
  import Ecto.Query, warn: false
  def create_order(order) do
    BinbaseBackend.Repo.insert(order)
  end
end