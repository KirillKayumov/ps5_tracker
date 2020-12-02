defmodule Ps5Web.HealthCheckController do
  use Ps5Web, :controller

  def index(conn, _params) do
    send_resp(conn, 200, "")
  end
end
