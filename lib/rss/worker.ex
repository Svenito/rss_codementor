defmodule Rss.Worker do
  def loop do
    receive do
      {sender_pid, feed_url} ->
        send(sender_pid, {:ok, feed_items(feed_url)})

      _ ->
        IO.puts("Unable to handle message")
    end

    loop()
  end

  def feed_items(feed_url) do
    result =
      feed_url
      |> HTTPoison.get()
      |> parse_response

    case result do
      {:ok, items} -> items
      :error -> %{}
    end
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    case FastRSS.parse(body) do
      {:ok, rss_map} -> {:ok, rss_map}
      _ -> :error
    end
  end

  defp parse_response(_) do
    :error
  end
end
