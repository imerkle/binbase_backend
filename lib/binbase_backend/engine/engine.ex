defmodule BinbaseBackend.Engine do
    alias BinbaseBackend.Orders

    def match(order) do
        
        kind_inverse = order["kind"] |> BinbaseBackend.Utils.inverse_int()
        orderbook_inverse = get_orderbook(order["market_id"], kind_inverse)


        {order, modified_orders, trades} = scan_orders(orderbook_inverse, order)

        if length(modified_orders) > 0 do
           mo = update_orders(orderbook_inverse, modified_orders)
           set_orderbook(mo, order["market_id"], kind_inverse)
        end
        add_order(order, trades)
    end

    defp scan_orders([head|tail], order, modified_orders \\ [], trades \\ []) do
        if (order["kind"] == 0 and head["price"] <= order["price"]) or (order["kind"] == 1 and head["price"] >= order["price"]) do

            har = head |> rem_amount()
            oar =  order |> rem_amount()
            
            {oar, har, trade_amount} = 
             cond do
                oar > har -> 
                    x = oar - har
                    {x, 0, x}
                oar < har -> {0, har - oar, oar}
                oar == har -> {0, 0, oar}
             end
            
            order = order |> update_amount(oar)
            modified_order = head |> update_amount(har)
            
            {buy_id, sell_id} = 
            cond do
                order["kind"] == 0 -> {order["id"], head["id"]}
                order["kind"] == 1 -> {head["id"], order["id"]}
            end
            
            trades = if trade_amount != 0 do
                trades ++ [%{
                    "price" => head["price"],
                    "amount" => trade_amount,
                    "buy_id" => buy_id,
                    "sell_id" => sell_id,
                }]
            end || trades
            if oar > 0 and tail |> length() != 0 do
                scan_orders(tail, order, modified_orders ++ [modified_order], trades)
            end || {order, modified_orders ++ [modified_order], trades}
        end || {order, modified_orders, trades}
    end
    defp rem_amount(order) do
        order["amount"] - order["amount_filled"]
    end
    defp update_amount(order, amount_remaining) do
        %{order | "amount_filled" => order["amount"] - amount_remaining }
    end


    defp update_orders(orderbook, modified_orders) do
        start_index = length(modified_orders) - length(orderbook)
        end_index = if start_index == 0, do: 0 ,else: -1
        orderbook = orderbook.slice(start_index..end_index)

        modified_orders = Enum.filter(modified_orders, fn x-> 
            Orders.update_order(x)
            x["amount"] != x["amount_filled"]
        end)
        modified_orders ++ orderbook
    end

    defp add_order(order, trades) do
        orderbook = get_orderbook(order["market_id"], order["kind"])
        tl = length(trades)
        o = cond do
            tl > 0 and order["amount"] != order["amount_filled"] -> [order] ++ orderbook
            tl == 0 -> 
                [order] ++ orderbook |> Enum.sort(fn (x, y) -> 
                    n = x["amount"] ==  y["amount"]
                    if n == true do
                        x["id"] <  y["id"]
                    else
                        x["amount"] <  y["amount"]
                    end
                end)
            true -> nil
        end
        if o != nil do
            Orders.update_order(order)
            set_orderbook(o, order["market_id"], order["kind"])
        end
    end

    defp get_orderbook(market_id, kind) do
        ConCache.get(:orderbook, "#{market_id}_#{kind}") || []
    end
    defp set_orderbook(orderbook, market_id, kind) do
        ConCache.update(:orderbook, "#{market_id}_#{kind}", orderbook)
    end


        
end


