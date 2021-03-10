defmodule RssWeb.PageLive do
  use RssWeb, :live_view
  import Rss.Rss

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{}, running: false)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    queries = String.split(query, "\n", trim: true)

    {:noreply,
     socket
     |> assign(results: rss_items(queries), query: query)}
  end
end
