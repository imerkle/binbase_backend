defmodule BinbaseBackendWeb.OrderController do
    use BinbaseBackendWeb, :controller
    alias BinbaseBackend.Order
    alias BinbaseBackend.Orders
    
    def create_order(conn, %{"token_rel" => token_rel, "token_base" => token_base, "kind" => kind, "price" => price, "amount" => amount}) do
        {_, data} = 
        %Order{} 
        |> Order.changeset(%{
            maker_id: conn.assigns.user,
            token_rel: token_rel,
            token_base: token_base,
            kind: kind,
            price: price,
            amount: amount,
        })
        |> Orders.create_order()
	  json(conn, data)
    end
    def get_orders(conn, %{"token_rel" => token_rel, "token_base" => token_base, "kind" => kind}) do
        kind = kind |> Integer.parse() |> elem(0)
        res = Orders.get_orders(token_rel, token_base, kind)
        json(conn, res)
    end
end