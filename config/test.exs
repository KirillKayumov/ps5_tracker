use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
# config :ps5, Ps5.Repo,
#   username: "postgres",
#   password: "postgres",
#   database: "ps5_test#{System.get_env("MIX_TEST_PARTITION")}",
#   hostname: "localhost",
#   pool: Ecto.Adapters.SQL.Sandbox

if System.get_env("DATABASE_URL") do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :ps5, Ps5.Repo,
    ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    pool: Ecto.Adapters.SQL.Sandbox
else
  config :ps5, Ps5.Repo,
    username: "postgres",
    password: "postgres",
    database: "ps5_test#{System.get_env("MIX_TEST_PARTITION")}",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox
end

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ps5, Ps5Web.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
