# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :binbase_backend,
  ecto_repos: [BinbaseBackend.Repo]

# Configures the endpoint
config :binbase_backend, BinbaseBackendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+2nW8L9TJBZHd2J87LvcxVTJVcqhF8++ncRR/ewPnQUDRB1u8cwq9tp9ZaJFJEVe",
  render_errors: [view: BinbaseBackendWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BinbaseBackend.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :warning,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :binbase_backend,
  hashid_salt: "bhd7i7FPegcSqHlWxews",
  phx_token_salt: "user salt"

  
import_config "#{Mix.env()}.exs"
