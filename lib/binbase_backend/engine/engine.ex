defmodule BinbaseBackend.Engine do
    alias BinbaseBackend.Orders
    alias BinbaseBackend.Order

    def match(order) do
        order = order |> Map.delete("inserted_at") |> Map.delete("updated_at") |> Map.put("stop_price", 0.0) |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        order = struct(Order, order)
        kind = order.kind
        kind_inverse = !kind
        market_id = order.market_id

        orderbook = get_orderbook(market_id, kind)
        orderbook_inverse = get_orderbook(market_id, kind_inverse)

        {:ok, outputs} = BinbaseBackend.Engine.Native.match_order(order, orderbook, orderbook_inverse)

        set_orderbook(outputs.orderbook, market_id, kind)
        update_order_db(outputs.order)
        if length(outputs.modified_orders) > 0 do
            Enum.map(outputs.modified_orders, fn x->
                update_order_db(x)
            end)
            set_orderbook(outputs.orderbook_inverse, market_id, kind_inverse)
        end
    end

    defp get_orderbook(market_id, kind) do
        ConCache.get(:orderbook, "#{market_id}_#{kind}") || []
    end
    defp set_orderbook(orderbook, market_id, kind) do
        ConCache.update(:orderbook, "#{market_id}_#{kind}", fn(_) ->
            {:ok, orderbook}
        end
        )
    end
    defp update_order_db(order) do
        case Mix.env() do
            :test -> Orders.update_order(order)
            n when n in [:dev, :prod] -> BinbaseBackend.Engine.Broadcaster.broadcast(order |> Jason.encode!(), "update_order")
        end

    end



end


