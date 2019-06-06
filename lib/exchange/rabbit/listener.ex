defmodule Exchange.Rabbit.Listener do
  use GenServer
  require Logger




  @moduledoc """
  Listens to events directly sent from workers to the
  engine. Performs the operations associated with the
  events using the main Engine module, which on success,
  broadcast them back to all workers. This acts as an
  acknowledgement, updating the workers Web UI state.

  NOTE:
  This is inefficient. For making this app "truly"
  distributed, consider having atleast a volatile state
  for each worker (maybe as a process?). This way we
  can reflect changes in UI instantly, and eventually
  support CQRS for partition tolerance.

  Also create a separate GenServer for handling RPC
  requests.
  """


  @queue    "exchange.queue"
  @exchange "exchange.exchange"
  @routing  "exchange.routing"




  ## Public API
  ## ----------


  @doc "Open the connection"
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end




  ## Callbacks
  ## ---------


  # Initialize State
  @doc false
  def init(:ok) do
    # Create Connection & Channel
    {:ok, connection} = AMQP.Connection.open("amqp://rabbitmq:rabbitmq@" <> Application.get_env(:exchange, :rabbitmq_host))
    {:ok, channel}    = AMQP.Channel.open(connection)

    # Declare Exchange & Queue
    AMQP.Exchange.declare(channel, @exchange, :direct)
    AMQP.Queue.declare(channel, @queue, durable: false)
    AMQP.Queue.bind(channel, @queue, @exchange, routing_key: @routing)

    # Start Consuming
    AMQP.Basic.consume(channel, @queue, nil, no_ack: true)

    {:ok, channel}
  end



  # Receive Messages
  @doc false
  def handle_info({:basic_deliver, payload, meta}, channel) do
    Logger.debug("Received Payload: #{inspect payload}")

    spawn fn ->
      consume(channel, payload, meta)
    end

    {:noreply, channel}
  end



  # Discard all other messages
  @doc false
  def handle_info(message, state) do
    Logger.debug("Received info: #{inspect message}")
    {:noreply, state}
  end


  defp consume(_channel, payload, %{type: "match"}) do
    Exchange.Engine.match(payload |> Jason.decode!())
  end

  defp consume(_channel, payload, %{type: "update_order"}) do
    Exchange.Orders.update_order(payload |> Jason.decode!())
  end

  # Handle unknown message types
  defp consume(_channel, _payload, meta) do
    #[:app_id, :cluster_id, :consumer_tag, :content_encoding, :content_type, :correlation_id, :delivery_tag, :exchange, :expiration, :headers, :message_id,:persistent, :priority, :redelivered, :reply_to, :routing_key, :timestamp, :type, :user_id]

    Logger.error("Unknown Message Type. Supplied Metadata: #{inspect(meta)}")
  end


end
