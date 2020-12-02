defmodule Mix.Tasks.HealthCheck do
  @timeout 5 * 60_000

  def run(_) do
    HTTPoison.start()

    perform()
  end

  defp perform do
    Process.send_after(self(), :health_check, @timeout)

    receive do
      :health_check ->
        "HEALTH_CHECK_URL"
        |> System.get_env()
        |> HTTPoison.get()
    end

    perform()
  end
end
