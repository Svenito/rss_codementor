defmodule Rss.Rss do
  # Handle messages from RSS parser processes handling those that
  # errored and those that worked. Store these in maps. Errored URLs are
  # stored under the :error key, and the :ok key stores the parsed feeds
  # Once the expected number of feeds has been parsed send :exit message and
  # return the map
  defp loop(%{ok: results, error: urls} \\ %{ok: [], error: []}, results_expected) do
    receive do
      {:ok, result} ->
        new_results = [result | results]

        if results_expected == Enum.count(new_results) + Enum.count(urls) do
          send(self(), :exit)
        end

        loop(%{ok: new_results, error: urls}, results_expected)

      {:error, url} ->
        new_urls = [url | urls]

        if results_expected == Enum.count(new_urls) + Enum.count(results) do
          send(self(), :exit)
        end

        loop(%{ok: results, error: new_urls}, results_expected)

      :exit ->
        %{ok: results, error: urls}

      _ ->
        loop(%{ok: results, error: urls}, results_expected)
    end
  end

  def rss_items([]) do
    %{ok: [], error: []}
  end

  def rss_items(feeds) do
    # Spawn RSS fetcher & parser. One for each feed
    feeds
    |> Enum.map(fn feed ->
      worker_pid = spawn(Rss.Worker, :loop, [])
      send(worker_pid, {self(), feed})
    end)

    # Process messages from workers until all have been processed
    loop(%{ok: [], error: []}, Enum.count(feeds))
  end
end
