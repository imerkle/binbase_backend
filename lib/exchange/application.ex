defmodule Exchange.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Exchange.MainSupervisor,
      # Start the endpoint when the application starts
      ExchangeWeb.Endpoint,
      # Starts a worker by calling: Exchange.Worker.start_link(arg)
      # {Exchange.Worker, arg},
      {ConCache, [name: :orderbook, ttl_check_interval: false]},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exchange.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExchangeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
