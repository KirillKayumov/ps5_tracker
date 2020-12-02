defmodule Ps5Web.PageController do
  use Ps5Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
