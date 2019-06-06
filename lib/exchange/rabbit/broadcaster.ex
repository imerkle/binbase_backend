defmodule Exchange.Rabbit.Broadcaster do
  use GenServer

  @exchange "exchange.exchange"
  @routing  "exchange.routing"


  @moduledoc """
  Keeps a RabbitMQ connection open to a fanout exchange
  where each worker is connected to. When messages are
  broadcasted, they're sent to all workers, and also to
  all the Phoenix channels (locally, on each instance).
  """




  ## Public API
  ## ----------


  @doc "Open the connection"
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end


  @doc "Broadcast event on the direct exchange"
  def broadcast(payload, cmd) do
    GenServer.cast(__MODULE__, {:broadcast, payload, cmd})
  end





  ## Callbacks
  ## ---------


  # Initialize State
  @doc false
  def init(:ok) do
    # Create Connection & Channel
    {:ok, connection} = AMQP.Connection.open("amqp://rabbitmq:rabbitmq@" <> Application.get_env(:exchange, :rabbitmq_host) )
    {:ok, channel}    = AMQP.Channel.open(connection)

    # Declare Fanout Exchange
    AMQP.Exchange.declare(channel, @exchange, :direct)

    {:ok, channel}
  end



  # Handle cast for :broadcast
  @doc false
  def handle_cast({:broadcast, payload, cmd}, channel) do

    # Broadcast on both Websocket and RabbitMQ
    #, [type: "event"]
    ExchangeWeb.Endpoint.broadcast!(cmd, "ping", %{payload: payload})
    AMQP.Basic.publish(channel, @exchange, @routing, payload, [type: cmd])
    {:noreply, channel}
  end



  # Discard all info messages
  @doc false
  def handle_info(_message, state) do
    {:noreply, state}
  end


end
