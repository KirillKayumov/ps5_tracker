defmodule Ps5.Track do
  use ExUnit.Case
  use Wallaby.Feature

  import Wallaby.Query, only: [css: 2, text_field: 1, button: 1]

  feature "users can create todos", %{session: session} do
    defmodule Kek do
      def kek(session) do
        session
        |> visit(
          "https://www.mediaexpert.pl/gaming/playstation-5/konsole-ps5/konsola-sony-ps5-digital"
        )
        |> take_screenshot()
      end
    end

    Kek.kek(session)
  end
end
