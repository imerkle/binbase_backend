defmodule BinbaseBackendWeb.OrderControllerTest do
  use BinbaseBackendWeb.ConnCase

  alias BinbaseBackend.Errors
  import BinbaseBackend.Factory

  test "/create_order", %{conn: conn} do
    price = 1000
    order = %{"token_rel" => "BTC", "token_base" => "USDT", "side" => false, "price" => price, "amount" => 500}
    response = conn
    |> put_req_header("authorization", "Bearer #{token()}")
    |> post(Routes.order_path(conn, :create_order, order))
    |> json_response(200)

    assert response["price"] == price
  end

  test "invalid /create_order", %{conn: conn} do
    price = "abcd"
    order = %{"token_rel" => "BTC", "token_base" => "USDT", "side" => false, "price" => price, "amount" => 500}
    response = conn
    |> put_req_header("authorization", "Bearer #{token()}")
    |> post(Routes.order_path(conn, :create_order, order))
    |> json_response(200)

    assert response == Errors.returnCodeBare("cant_create_order")
  end

end
