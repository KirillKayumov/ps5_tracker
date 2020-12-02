defmodule Ps5.Repo do
  use Ecto.Repo,
    otp_app: :ps5,
    adapter: Ecto.Adapters.Postgres
end
