defmodule BinbaseBackendWeb.TradeChannel do

    @channel "trade"

    def join(@channel, _payload, socket) do
        {:ok, socket}
    end

    # Handle Events

    def handle_out("trade:order", payload, socket) do
        {:noreply, socket}
    end    
end
