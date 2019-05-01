defmodule BinbaseBackend.OrdersTest do
    use BinbaseBackend.DataCase, async: true
    alias BinbaseBackend.Orders
    alias BinbaseBackend.Errors

    @token_rel "BTC"
    @token_base "USDT"
    @maker_id 1

    test "order matching" do


        #sell orders created to match itselves
        orders = [
            %{
                side: false,
                price: 6001,
                amount: 100,
                #trigger_at: 6010
            },
            #100
            #0
            %{
                side: false,
                price: 6010,
                amount: 200
            },
            #300
            #0
            %{
                side: true,
                price: 90000,
                amount: 500,
                kind: 2,
            },
            #0
            #200
            %{
                side: false,
                price: 6010,
                amount: 250,
            },
            #50
            #0
            %{
                side: true,
                price: 6009,
                amount: 155,
            },
            #0
            #105
            %{
                side: false,
                price: 0,
                amount: 105,
                kind: 2,
            },
        ]
        orders = Enum.map(orders, fn x ->
            {:ok, order} = Orders.create_order(@maker_id, @token_rel, @token_base, x.side, x.price, x.amount, [kind: Map.get(x, :kind, 0), trigger_at: Map.get(x, :trigger_at)])
            order
        end)
        Enum.map(orders, fn x ->
            assert BinbaseBackend.Repo.get(BinbaseBackend.Order, x.id).amount_filled == x.amount
        end)
    end
    test "order matching failed" do
        assert Orders.create_order(@maker_id, @token_rel, @token_base, false, 10000000000, 10000000000) == Errors.returnCode("not_enough_balance")
    end
end
