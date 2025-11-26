defmodule MemoizerOfRecommendations do
  use GenServer

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(_ops) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_recommendations(number_of_items_in_cart, time_spent_on_website) do
    GenServer.call(
      __MODULE__,
      {:get_recommendations, number_of_items_in_cart, time_spent_on_website}
    )
  end

  @impl true
  def handle_call(
        {:get_recommendations, number_of_items_in_cart, time_spent_on_website},
        _from,
        cache
      ) do
    {value, cache} = get_from_cache(number_of_items_in_cart, time_spent_on_website, cache)
    {:reply, value, cache}
  end

  defp get_from_cache(number_of_items_in_cart, time_spent_on_website, cache) do
    result = Map.get(cache, {number_of_items_in_cart, time_spent_on_website})

    if result == nil do
      recommendations = calculate_recommendations(number_of_items_in_cart, time_spent_on_website)

      new_cache =
        Map.put(cache, {number_of_items_in_cart, time_spent_on_website}, recommendations)

      IO.puts("Cache miss. Calculating...")
      {recommendations, new_cache}
    else
      IO.puts("Cache hit")
      {result, cache}
    end
  end

  defp calculate_recommendations(number_of_items_in_cart, time_spent_on_website) do
    case {number_of_items_in_cart, time_spent_on_website} do
      {0, 55} -> [:car, :toys, :candy]
      {0, 30} -> [:huntingstuff, :campingstuff, :fisingstuff]
      _ -> [:everything]
    end
  end
end

{:ok, _pid} = MemoizerOfRecommendations.start_link([])
value = MemoizerOfRecommendations.get_recommendations(0, 55)
IO.inspect(value)
value = MemoizerOfRecommendations.get_recommendations(0, 55)
IO.inspect(value)
value = MemoizerOfRecommendations.get_recommendations(4, 192)
IO.inspect(value)
value = MemoizerOfRecommendations.get_recommendations(0, 30)
IO.inspect(value)
value = MemoizerOfRecommendations.get_recommendations(4, 192)
IO.inspect(value)
value = MemoizerOfRecommendations.get_recommendations(4, 192)
IO.inspect(value)
IO.puts("Done")
