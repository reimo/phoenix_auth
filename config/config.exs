# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix_auth,
  ecto_repos: [PhoenixAuth.Repo]

# Configures the endpoint
config :phoenix_auth, PhoenixAuthWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4J4p7tPWoStA8nmCNxoBSj9Hu/d5uhJO7ma7cJ9WMHXbV3cHv3mdoKmdU0QL4OGm",
  render_errors: [view: PhoenixAuthWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixAuth.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


config :phoenix_auth, PhoenixAuth.Guardian,
  issuer: "PhoenixAuth",
  secret_key: "4J4p7tPWoStA8nmCNxoBSj9Hu/d5uhJO7ma7cJ9WMHXbV3cHv3mdoKmdU0QL4OGm"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
