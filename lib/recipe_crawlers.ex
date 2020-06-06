defmodule RecipeCrawlers do
  @moduledoc """
  Documentation for RecipeCrawlers.
  """

  @doc """
  Hello world.

  ## Examples

      iex> RecipeCrawlers.hello()
      :world

  """
  def hello do
    :world
  end

  def crawl() do
    :ok = RecipeCrawlers.MyKafkaProducer.start()
    {:ok, producer} = RecipeCrawlers.Producer.start_link("map_RecipePagesGroup_https_yandex_0.xml")
    {:ok, consumer} = RecipeCrawlers.Consumer.start_link()
    {:ok, _} = GenStage.sync_subscribe(consumer, to: producer)
  end
end
