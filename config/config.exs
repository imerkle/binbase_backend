# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :exchange,
  ecto_repos: [Exchange.Repo]

# Configures the endpoint
config :exchange, ExchangeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+2nW8L9TJBZHd2J87LvcxVTJVcqhF8++ncRR/ewPnQUDRB1u8cwq9tp9ZaJFJEVe",
  render_errors: [view: ExchangeWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Exchange.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :warning,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :exchange,
  hashid_salt: "bhd7i7FPegcSqHlWxews",
  phx_token_salt: "user salt"

config :postgrex, :json_library, Jason

import_config "#{Mix.env()}.exs"
