defmodule Rss.Rss do
  def loop(results \\ [], results_expected) do
    receive do
      {:ok, result} ->
        new_results = [result | results]

        if results_expected == Enum.count(new_results) do
          send(self(), :exit)
        end

        loop(new_results, results_expected)

      :exit ->
        results

      _ ->
        loop(results, results_expected)
    end
  end

  def rss_items(feeds) do
    feeds
    |> Enum.map(fn feed ->
      worker_pid = spawn(Rss.Worker, :loop, [])
      send(worker_pid, {self(), feed})
    end)

    loop([], Enum.count(feeds))

    # Enum.each(fn x -> print_feed(x) end)
  end
end
