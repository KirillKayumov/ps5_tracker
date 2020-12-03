# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ps5,
  ecto_repos: [Ps5.Repo]

# Configures the endpoint
config :ps5, Ps5Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "G9uX6maq679pvAUH5LvQ0+5HDwO8nBhCzk5OFq+dtclyB8EjphbdIj9MD0Sd8x3B",
  render_errors: [view: Ps5Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Ps5.PubSub,
  live_view: [signing_salt: "fqLiL16X"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :wallaby,
  driver: Wallaby.Chrome,
  otp_app: :ps5,
  chromedriver: [
    path: System.get_env("HOME") <> "/.chromedriver/bin/chromedriver",
    binary: System.get_env("GOOGLE_CHROME_SHIM")
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
