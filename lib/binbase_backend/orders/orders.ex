defmodule BinbaseBackend.Orders do

  import Ecto.Query, warn: false
  alias BinbaseBackend.Repo
  alias BinbaseBackend.Order
  alias BinbaseBackend.Utils
  alias BinbaseBackend.Engine
  def create_order(maker_id, token_rel, token_base, kind, price, amount) do
    market_id = Utils.market_id(token_rel, token_base)


    order = %Order{}
    |> Order.changeset(%{
        maker_id: maker_id,
        market_id: market_id,
        kind: kind,
        price: price,
        amount: amount,
        amount_filled: 0.0,
    })

    {:ok, x} = Repo.insert(order)

    case Mix.env() do
      n when n in [:dev, :prod] -> Engine.Broadcaster.broadcast(x |> Jason.encode!(), "match")
      :test-> Engine.match(x |> Jason.encode!() |> Jason.decode!())
    end

    {:ok, x}
  end
  def get_orders(token_rel, token_base, kind, lm \\ 20) do
    market_id = Utils.market_id(token_rel, token_base)
    q = Order
    |> where([x], x.market_id == ^market_id and x.kind == ^kind)

    q = if kind == 0, do: q |> order_by(desc: :price), else: q |> order_by(asc: :price)

    q
    |> limit(^lm)
    |> Repo.all()
  end
  def update_order(order) do
    %Order{id: order["id"]} |> Order.changeset(%{amount_filled: order["amount_filled"]}) |> Repo.update()
  end
end
