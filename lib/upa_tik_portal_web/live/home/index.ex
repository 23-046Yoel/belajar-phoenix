defmodule UpaTikPortalWeb.Home.Index do
  use UpaTikPortalWeb, :live_view

  # 1. Inisialisasi Data
  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # 2. Reaksi Terhadap URL (Live Action)
  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end

  # 3. Menangani Interaksi User (Event)
  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:noreply, socket}
  end
end
