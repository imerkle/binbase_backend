defmodule Exchange.OrdersTest do
    use Exchange.DataCase, async: true
    alias Exchange.Orders
    alias Exchange.Balance
    alias Exchange.Errors

    import Exchange.Factory

    @token_rel "BTC"
    @token_base "USDT"
    @maker_id 1

    test "order matching" do


        #sell orders created to match itselves
        orders = [
            %{
                side: false,
                price: 6001,
                amount: 1,
                #trigger_at: 6010
            },
            #100
            #0
            %{
                side: false,
                price: 6010,
                amount: 2
            },
            #300
            #0
            %{
                side: true,
                price: 90000,
                amount: 5,
                kind: 2,
            },
            #0
            #200
            %{
                side: false,
                price: 6010,
                amount: 2.5,
            },
            #50
            #0
            %{
                side: true,
                price: 6009,
                amount: 1.55,
            },
            #0
            #105
            %{
                side: false,
                price: 0,
                amount: 1.05,
                kind: 2,
            },
        ]
        orders = Enum.map(orders, fn x ->
            {:ok, order} = Orders.create_order(@maker_id, @token_rel, @token_base, x.side, x.price, x.amount, [kind: Map.get(x, :kind, 0), trigger_at: Map.get(x, :trigger_at)])
            order
        end)
        Enum.map(orders, fn x ->
            assert Exchange.Repo.get(Exchange.Order, x.id).amount_filled == x.amount
        end)
    end
    test "order matching adjust balance" do

        user = insert_user()
        {:ok, _} = Balance.insert_balance(user.id, @token_base, 10000)
        b = Balance.get_balance(user.id, @token_base)

        assert b == 10000

        {:ok, order} = Orders.create_order(2, @token_rel, @token_base, false, 10000, 1)

        b = Balance.get_balance(user.id, @token_base)
        assert b == 0

    end
    test "order matching failed" do
        assert Orders.create_order(@maker_id, @token_rel, @token_base, false, 10000000000, 10000000000) == Errors.returnCode("not_enough_balance")
    end
end
