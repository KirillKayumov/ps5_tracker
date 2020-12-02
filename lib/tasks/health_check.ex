defmodule Mix.Tasks.HealthCheck do
  @health_check_timeout 5 * 60_000
  @ps5_timeout System.get_env("PS5_TIMEOUT") |> String.to_integer()

  @mediaexpert_url "https://www.mediaexpert.pl/gaming/playstation-5/konsole-ps5/konsola-sony-ps5-digital"

  def run(_) do
    HTTPoison.start()

    perform()
  end

  defp perform do
    Process.send_after(self(), :health_check, @health_check_timeout)
    Process.send_after(self(), :check_ps5, @ps5_timeout)

    receive do
      :health_check -> make_health_check_request()
      :check_ps5 -> check_ps5_in_mediaexpert()
    end

    perform()
  end

  defp make_health_check_request do
    "HEALTH_CHECK_URL"
    |> System.get_env()
    |> HTTPoison.get()
  end

  defp check_ps5_in_mediaexpert do
    response = HTTPoison.get!(@mediaexpert_url)
    {:ok, document} = Floki.parse_document(response.body)

    not_available =
      document
      |> Floki.find(".is-notAvailable")
      |> Floki.text()
      |> String.replace("\n", "")
      |> String.replace(~r/\s+/, " ")
      |> String.contains?("Produkt chwilowo niedostępny w sklepie internetowym")

    case not_available do
      true -> IO.puts("Not available in MediaExpert")
      false -> IO.puts("Available!")
    end
  end
end
