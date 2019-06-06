defmodule ExchangeWeb.OrderController do
    use ExchangeWeb, :controller
    alias Exchange.Orders

    def create_order(conn, %{"token_rel" => token_rel, "token_base" => token_base, "side" => side, "price" => price, "amount" => amount} = params) do
        trigger_at = Map.get(params, "trigger_at", nil)
        kind = Map.get(params, "kind", 0)

        {_, data} = Orders.create_order(conn.assigns.user, token_rel, token_base, side, price, amount, [kind: kind, trigger_at: trigger_at])

        json(conn, data)
    end
    def get_orders(conn, %{"token_rel" => token_rel, "token_base" => token_base, "side" => side}) do
        side = side |> Integer.parse() |> elem(0)
        res = Orders.get_orders(token_rel, token_base, side)
        json(conn, res)
    end
end
