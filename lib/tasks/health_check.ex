defmodule Mix.Tasks.HealthCheck do
  @health_check_timeout 5 * 60_000

  @mediaexpert_digital_url "https://www.mediaexpert.pl/gaming/playstation-5/konsole-ps5/konsola-sony-ps5-digital"
  @mediaexpert_url "https://www.mediaexpert.pl/gaming/playstation-5/konsole-ps5/konsola-sony-ps5"

  @eurocom_digital_url "https://www.euro.com.pl/konsole-playstation-5/sony-konsola-playstation-5-edycja-digital-ps5.bhtml"
  @eurocom_url "https://www.euro.com.pl/konsole-playstation-5/sony-konsola-playstation-5-ps5-blu-ray-4k.bhtml"

  @mediamarkt_url "https://mediamarkt.pl/konsole-i-gry/playstation-5-dodatkowy-kontroler-dualsense-fifa-21-edycja-mistrzowska-steelbook"

  @mvideo_digital_url "https://www.mvideo.ru/products/igrovaya-konsol-sony-playstation-5-digital-edition-40074203"

  @me 70_067_678
  @ilyas 58_246_450
  @arkadiy 60_717_876

  # @ilyas 1
  # @arkadiy 2

  def run(_) do
    HTTPoison.start()
    {:ok, _} = Application.ensure_all_started(:wallaby)

    Process.send_after(self(), :health_check, @health_check_timeout)
    Process.send_after(self(), :check_ps5, ps5_timeout())

    perform()
  end

  defp perform() do
    {:ok, session} = Wallaby.start_session()

    try do
      receive do
        :health_check ->
          make_health_check_request()

          Process.send_after(self(), :health_check, @health_check_timeout)

        :check_ps5 ->
          check_ps5_in_mediaexpert(@mediaexpert_digital_url)
          check_ps5_in_mediaexpert(@mediaexpert_url)
          check_ps5_in_eurocom(@eurocom_digital_url, session)
          check_ps5_in_eurocom(@eurocom_url, session)
          check_ps5_in_mediamarkt(@mediamarkt_url, session)
          check_ps5_in_mvideo(@mvideo_digital_url)

          Process.send_after(self(), :check_ps5, ps5_timeout())
      end
    rescue
      _ ->
        IO.puts("something went wrong with Chrome")
        Process.send_after(self(), :check_ps5, ps5_timeout())
        :ok
    end

    close_session(session)
    perform()
  end

  defp close_session(session) do
    Wallaby.end_session(session)
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
      true ->
        IO.puts("Not available in MediaExpert")

      false ->
        notify("PS5 AVAILABLE #{url}", @me)
        notify("PS5 AVAILABLE #{url}", @arkadiy)
    end
  end

  defp check_ps5_in_eurocom(url, session) do
    Wallaby.Browser.visit(session, url)
    :timer.sleep(:timer.seconds(5))

    no_delivery = Wallaby.Browser.has_text?(session, "Brak możliwości dostawy")

    add_to_cart =
      Wallaby.Browser.has?(
        session,
        Wallaby.Query.css("button") |> Wallaby.Query.text("DO KOSZYKA")
      )

    case !no_delivery || add_to_cart do
      true ->
        notify("PS5 AVAILABLE #{url}", @me)
        notify("PS5 AVAILABLE #{url}", @arkadiy)

      false ->
        IO.puts("Not available in Euro.com")
    end
  end

  defp check_ps5_in_mediamarkt(url, session) do
    Wallaby.Browser.visit(session, url)
    :timer.sleep(:timer.seconds(5))

    is_bot = Wallaby.Browser.has_text?(session, "Bot Traffic Warning")
    no_delivery = Wallaby.Browser.has_text?(session, "Produkt chwilowo niedostępny")

    case is_bot || no_delivery do
      true ->
        IO.puts("Not available in MediaMarkt")

      false ->
        notify("PS5 AVAILABLE #{url}", @me)
        notify("PS5 AVAILABLE #{url}", @arkadiy)
    end
  end

  defp check_ps5_in_mvideo(url) do
    response = HTTPoison.get!(url)
    {:ok, document} = Floki.parse_document(response.body)

    not_available =
      document
      |> Floki.find(".o-container__price-column .c-notifications__title")
      |> Floki.text()
      |> String.replace("\n", "")
      |> String.replace(~r/\s+/, " ")
      |> String.contains?("Товар распродан")

    case not_available do
      true ->
        IO.puts("Not available in Mvideo")

      false ->
        notify("PS5 AVAILABLE #{url}", @ilyas)
        notify("PS5 AVAILABLE #{url}", @me)
    end
  end

  def notify(text, chat_id) do
    HTTPoison.post!(
      "https://api.telegram.org/bot948991611:AAFMr_C_w1eUHtGE9e4HoU6__NlH6WFQ4HQ/sendMessage",
      Poison.encode!(%{text: text, chat_id: chat_id}),
      [{"Content-Type", "application/json"}]
    )
  end

  defp make_health_check_request do
    "HEALTH_CHECK_URL"
    |> System.get_env()
    |> HTTPoison.get()
  end
end
