defmodule BinbaseBackend.Engine do

    alias BinbaseBackend.Trade
    alias BinbaseBackend.Balance
    def match(order) do

        #|> Map.delete("inserted_at") |> Map.delete("updated_at")
        #order = order |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        #order = struct(Order, order)

        side = order.side
        side_inverse = !side
        market_id = order.market_id

        orderbook = get_orderbook(market_id, side)
        orderbook_inverse = get_orderbook(market_id, side_inverse)
        {:ok, outputs} = BinbaseBackend.Engine.Native.match_order(order, orderbook, orderbook_inverse)


        #cache update orderbooks
        set_orderbook(outputs.orderbook, market_id, side)
        if length(outputs.modified_orders) > 0 do
            set_orderbook(outputs.orderbook_inverse, market_id, side_inverse)
        end
        #repo multi update moditradesfied orders and taker order
        BinbaseBackend.Orders.update_all(outputs.modified_orders, outputs.order)
        #repo multi insert modified orders
        Trade.insert_all(outputs.trades)
        a = Balance.update_all(outputs.balances)

        lt = length(outputs.trades)
        lo = length(outputs.orderbook)
        lo1 = length(outputs.orderbook_inverse)
        if (lt > 0 or (lo == 0 or lo1 == 0) ) or (lt > 0 and (lo > 0 or lo1 > 0) ) do
            o = Enum.at(orderbook, 0) || %{id: 0, price: 0}
            o1 = Enum.at(orderbook_inverse, 0) || %{id: 0, price: 0}
            p = if o.id > o1.id, do: o.price, else: o1.price
            BinbaseBackend.Trigger.hit(order.market_id, order.price, p)
        end


    end

    defp get_orderbook(market_id, side) do
        ConCache.get(:orderbook, "#{market_id}_#{side}") || []
    end

    defp set_orderbook(orderbook, market_id, side) do
        ConCache.update(:orderbook, "#{market_id}_#{side}", fn(_) ->
            {:ok, orderbook}
        end
        )
    end
end
