defmodule RssWeb.PageLive do
  use RssWeb, :live_view
  import Rss.Rss

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{}, errors: %{})}
  end

  def handle_event("search", %{"q" => ""}, socket) do
    {:noreply,
     socket
     |> assign(results: %{}, errors: %{}, query: "")}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    queries = String.split(query, "\n", trim: true)

    # Join them and to show non-empy lines only
    valid_queries = Enum.join(queries, "\n")

    feeds = rss_items(queries)

    {:noreply,
     socket
     |> assign(results: feeds[:ok], errors: feeds[:error], query: valid_queries)}
  end
end
