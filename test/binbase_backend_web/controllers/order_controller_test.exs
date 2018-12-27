defmodule BinbaseBackendWeb.OrderControllerTest do
  use BinbaseBackendWeb.ConnCase

  import BinbaseBackend.Factory
  alias BinbaseBackend.Errors

  test "create_order/1", %{conn: conn} do
    order = %{"token_rel" => "BTC", "token_base" => "USDT", "kind" => 0, "price" => 3854, "amount" => 500}
    response = conn
    |> put_req_header("authorization", "Bearer #{token()}")
    |> post(Routes.order_path(conn, :create_order, order))
    |> json_response(200)
    
    assert response["token_base"] == "USDT"
    assert response["price"] == 3854
  end

end