defmodule Mix.Tasks.HealthCheck do
  @health_check_timeout 5 * 60_000

  @mediaexpert_digital_url "https://www.mediaexpert.pl/gaming/playstation-5/konsole-ps5/konsola-sony-ps5-digital"
  @mediaexpert_url "https://www.mediaexpert.pl/gaming/playstation-5/konsole-ps5/konsola-sony-ps5"

  def run(_) do
    HTTPoison.start()

    Process.send_after(self(), :health_check, @health_check_timeout)
    Process.send_after(self(), :check_ps5, ps5_timeout())

    perform()
  end

  defp perform do
    receive do
      :health_check ->
        make_health_check_request()

        Process.send_after(self(), :health_check, @health_check_timeout)

      :check_ps5 ->
        check_ps5_in_mediaexpert(@mediaexpert_digital_url)
        check_ps5_in_mediaexpert(@mediaexpert_url)

        Process.send_after(self(), :check_ps5, ps5_timeout())
    end

    perform()
  end

  defp ps5_timeout do
    System.get_env("PS5_TIMEOUT") |> String.to_integer()
  end

  defp check_ps5_in_mediaexpert(url) do
    response = HTTPoison.get!(url)
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
      false -> notify("PS5 AVAILABLE #{url}")
    end
  end

  defp notify(text) do
    HTTPoison.post!(
      "https://api.telegram.org/bot948991611:AAFMr_C_w1eUHtGE9e4HoU6__NlH6WFQ4HQ/sendMessage",
      Poison.encode!(%{text: text, chat_id: 70_067_678}),
      [{"Content-Type", "application/json"}]
    )
  end

  defp make_health_check_request do
    "HEALTH_CHECK_URL"
    |> System.get_env()
    |> HTTPoison.get()
  end
end
