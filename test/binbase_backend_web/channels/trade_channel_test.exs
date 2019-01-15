defmodule BinbaseBackendWeb.TradeChannelTest do
    use BinbaseBackendWeb.ChannelCase    

    setup do
    {:ok, _, socket} =
        socket("join", %{})
        |> subscribe_and_join(BinbaseBackendWeb.TradeChannel, "trade")

    {:ok, socket: socket}
    end

    test "something channel test", %{socket: socket} do

    end
end