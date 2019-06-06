defmodule ExchangeWeb.TradeChannelTest do
    use ExchangeWeb.ChannelCase
    import Exchange.Factory

    setup do
    {:ok, _, socket} =
        socket(ExchangeWeb.MainSocket,"main_socket", %{})
        |> subscribe_and_join(ExchangeWeb.TradeChannel, "trade")

    {:ok, socket: socket}
    end

    test "ping replies with status ok", %{socket: socket} do
        user = insert_user()
        _order = insert_order(user.id)
        ref = push socket, "ping", %{"hello" => "there"}
        assert_reply ref, :ok, %{message: "pong"}
    end
end
