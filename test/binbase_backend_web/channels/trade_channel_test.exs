defmodule BinbaseBackendWeb.TradeChannelTest do
    use BinbaseBackendWeb.ChannelCase    
    import BinbaseBackend.Factory

    setup do
    {:ok, _, socket} =
        socket("main_socket", %{})
        |> subscribe_and_join(BinbaseBackendWeb.TradeChannel, "trade")

    {:ok, socket: socket}
    end

    test "ping replies with status ok", %{socket: socket} do
        user = insert_user()
        order = insert_order(user.id)
        ref = push socket, "ping", %{"hello" => "there"}
        assert_reply ref, :ok, %{message: "pong"}
    end
end