defmodule RecipeCrawlers.MyKafkaProducer do
  @host [localhost: 9092]
  @topic "recipes"
  @client_id :recipe_crawler

  defmodule GenPartitions do
    use Agent

    @partitions_count 10

    def start_link() do
      Agent.start_link(fn -> 0 end, name: __MODULE__)
    end

    def next() do
      value = Agent.get(__MODULE__, & &1)
      Agent.update(__MODULE__, &(&1 + 1))
      rem(value, @partitions_count)
    end
  end

  def start() do
    {:ok, _} = GenPartitions.start_link()
    :ok = :brod.start_client(@host, @client_id, _client_config=[])
    :ok = :brod.start_producer(@client_id, @topic, _producer_config = [])
    :ok
  end

  def sync(value) do
    :brod.produce_sync(@client_id, @topic, GenPartitions.next(), "", value)
  end
end