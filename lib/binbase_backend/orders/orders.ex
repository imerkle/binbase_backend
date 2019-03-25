defmodule BinbaseBackend.Orders do
  
  import Ecto.Query, warn: false
  alias BinbaseBackend.Repo
  alias BinbaseBackend.Order

  def create_order(order) do
    {:ok, x} = Repo.insert(order)
    BinbaseBackend.Engine.Broadcaster.broadcast(x)
    {:ok, x}
  end
  def get_orders(token_rel, token_base, kind) do
    q = Order
    |> where([x], x.token_rel == ^token_rel and x.token_base == ^token_base and x.kind == ^kind)

    q = if kind == 0, do: q |> order_by(desc: :price), else: q |> order_by(asc: :price)
    
    r = q
    |> limit(2)
    |> Repo.all()
  end
end