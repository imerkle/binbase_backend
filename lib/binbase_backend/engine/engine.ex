defmodule BinbaseBackend.Engine do
    alias BinbaseBackend.Order

    def match(order) do
        #|> Map.delete("inserted_at") |> Map.delete("updated_at")
        order = order |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        order = struct(Order, order)

        kind = order.kind
        kind_inverse = !kind
        market_id = order.market_id

        orderbook = get_orderbook(market_id, kind)
        orderbook_inverse = get_orderbook(market_id, kind_inverse)
        {:ok, outputs} = BinbaseBackend.Engine.Native.match_order(order, orderbook, orderbook_inverse)


        #cache update orderbooks
        set_orderbook(outputs.orderbook, market_id, kind)
        if length(outputs.modified_orders) > 0 do
            set_orderbook(outputs.orderbook_inverse, market_id, kind_inverse)
        end

        #repo multi update modified orders and taker order
        BinbaseBackend.Orders.update_all(outputs.modified_orders, outputs.order)
        #repo multi insert modified orders
        BinbaseBackend.Trade.insert_all(outputs.trades)

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
end


