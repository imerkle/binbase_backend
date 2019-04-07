defmodule BinbaseBackendWeb.TradeChannel do
    use BinbaseBackendWeb, :channel

    @channel "trade"

    def join(@channel, _payload, socket) do
        {:ok, socket}
    end

    # Handle Events
    def handle_in("ping", _payload, socket) do
        {:reply, {:ok, %{message: "pong"}}, socket}
    end
#    def handle_out("ping", _payload, socket) do
#        {:reply, {:ok, %{message: "pongi"}}, socket}
#    end    
end
