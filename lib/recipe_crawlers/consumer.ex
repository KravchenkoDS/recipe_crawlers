defmodule RecipeCrawlers.Consumer do
  use GenStage

  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, :the_state_does_not_matter}
  end

  def handle_events(events, _from, state) do
    # IO.puts("received #{length(events)} events")
    Enum.each(events, &recipe_page/1)
    {:noreply, [], state}
  end

  defp recipe_page(%{loc: loc}) do
    resp = HTTPoison.get!(loc)
    if resp.status_code == 200 do
      {:ok, page} = Floki.parse_document(resp.body)
      item =
        page
        |> Floki.find("script[type=\"application/ld+json\"]")
        |> List.first()

      if !is_nil(item) do
        item
        |> Floki.children()
        |> Floki.text()
        |> IO.inspect()
        |> RecipeCrawlers.MyKafkaProducer.sync()
      end
    else
      Logger.error("Cannot download " <> loc)
    end
  end
end
