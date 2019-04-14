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
                "kind" => 0,
                "price" => 4000,
                "amount" => 100,
            },
            %{
                "kind" => 0,
                "price" => 4010,
                "amount" => 200,
            },
            %{
                "kind" => 1,
                "price" => 4000,
                "amount" => 500,
            },
            %{
                "kind" => 0,
                "price" => 4020,
                "amount" => 250,
            },
            %{
                "kind" => 1,
                "price" => 4018,
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
end
