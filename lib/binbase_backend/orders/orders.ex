defmodule BinbaseBackend.Orders do
  
  import Ecto.Query, warn: false
  alias BinbaseBackend.Repo
  alias BinbaseBackend.Order

  def create_order(order) do
    {:ok, x} = Repo.insert(order)
    BinbaseBackend.Engine.Broadcaster.broadcast(x |> Jason.encode!() )
    {:ok, x}
  end
  def get_orders(token_rel, token_base, kind, lm \\ 20) do
    market_id = BinbaseBackend.Utils.market_id(token_rel, token_base)
    q = Order
    |> where([x], x.market_id == ^market_id and x.kind == ^kind)

    q = if kind == 0, do: q |> order_by(desc: :price), else: q |> order_by(asc: :price)    
    
    q
    |> limit(^lm)
    |> Repo.all()
  end
  def update_order(order) do
    %Order{} |> Order.changeset(order) |> Repo.update()
  end
end