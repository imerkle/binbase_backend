defmodule BinbaseBackend.Orders do

  import Ecto.Query
  alias BinbaseBackend.Order
  alias BinbaseBackend.Utils
  alias BinbaseBackend.Engine
  alias BinbaseBackend.Rabbit
  alias BinbaseBackend.Trigger
  alias BinbaseBackend.Errors

  def create_order(maker_id, token_rel, token_base, kind, price, amount, trigger_at \\ nil) do
    market_id = Utils.market_id(token_rel, token_base)

    active = if trigger_at != nil, do: false, else: true
    order_changeset = Order.changeset(%Order{}, %{ maker_id: maker_id, market_id: market_id, kind: kind, price: price, amount: amount, active: active, })

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:order, order_changeset)
    |> Ecto.Multi.run(:trigger,fn repo, %{order: order} ->
      if !active do
        trigger_changeset = Trigger.changeset(%Trigger{}, %{market_id: market_id,order_id: order.id, trigger_at: trigger_at })
        a = repo.insert(trigger_changeset)
      else
        {:ok, nil}
      end
    end)
    |> BinbaseBackend.Repo.transaction()
    |> case do
      {:ok, result} ->
        if result.trigger == nil do
          case Mix.env() do
            n when n in [:dev, :prod] -> Rabbit.Broadcaster.broadcast(result.order |> Jason.encode!(), "match")
            :test-> Engine.match(result.order)
          end
        end
        {:ok, result.order}
      #https://web.archive.org/web/20181127084359/https://medium.com/appunite-edu-collection/handling-failures-in-elixir-and-phoenix-12b70c51314b
      {:error, _failed_operation, failed_value, _changes} -> Errors.returnCode("cant_create_order")
    end
  end
  def get_orders(token_rel, token_base, kind, lm \\ 20, active \\ true) do
    market_id = Utils.market_id(token_rel, token_base)
    q = Order
    |> where([x], x.market_id == ^market_id and x.kind == ^kind and x.active == ^active)

    q = if kind == false, do: q |> order_by(desc: :price), else: q |> order_by(asc: :price)

    q
    |> limit(^lm)
    |> BinbaseBackend.Repo.all()
  end

  def update_all(modified_orders, order) do
    modified_orders
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn ({order, index}, multi) ->
        Ecto.Multi.update(multi, Integer.to_string(index), update_order_db(order))
    end)
    |> Ecto.Multi.update(Integer.to_string(length(modified_orders)),update_order_db(order) )
    |> BinbaseBackend.Repo.transaction()
  end

  defp update_order_db(order) do
    %Order{id: order.id}
    |> Order.changeset(%{amount_filled: order.amount_filled})
  end
end
