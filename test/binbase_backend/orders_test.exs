defmodule BinbaseBackend.OrdersTest do
    use BinbaseBackend.DataCase, async: true
    alias BinbaseBackend.Orders

    test "order matching" do
        token_rel = "BTC"
        token_base = "USDT"
        maker_id = 1

        #sell orders created to match itselves
        orders = [
            %{
                "kind" => false,
                "price" => 6001,
                "amount" => 100,
            },
            %{
                "kind" => false,
                "price" => 6010,
                "amount" => 200,
            },
            %{
                "kind" => true,
                "price" => 6001,
                "amount" => 500,
            },
            %{
                "kind" => false,
                "price" => 6020,
                "amount" => 250,
            },
            %{
                "kind" => true,
                "price" => 6018,
                "amount" => 50,
            },
        ]

        orders = Enum.map(orders, fn x ->
            {:ok, order} = Orders.create_order(maker_id, token_rel, token_base, x["kind"], x["price"], x["amount"])
            order
        end)

        Enum.map(orders, fn x ->
            assert BinbaseBackend.Repo.get(BinbaseBackend.Order, x.id).amount_filled == x.amount
        end)
    end

    test "nifs" do
        #assert BinbaseBackend.Engine.Native.add(1,2)  == {:ok, 3}
    end
end
