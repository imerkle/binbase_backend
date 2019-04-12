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
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

#word lists
import_config "adjectives.exs"
import_config "nouns.exs"

config :binbase_backend,
  hashid_salt: "bhd7i7FPegcSqHlWxews",
  phx_token_salt: "user salt"
  config :binbase_backend, BinbaseBackend.Emails.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.sendgrid.net",
  hostname: "ricking06@gmail.com",
  port: 465,
  username: "apikey", # or {:system, "SMTP_USERNAME"}
  password: "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", # or {:system, "SMTP_PASSWORD"}
  tls: :if_available, # can be `:always` or `:never`
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  ssl: true, # can be `true`
  retries: 1,
  no_mx_lookups: false, # can be `true`
  auth: :if_available # can be `always`. If your smtp relay requires authentication set it to `always`.  
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

import_config "#{Mix.env()}.exs"
