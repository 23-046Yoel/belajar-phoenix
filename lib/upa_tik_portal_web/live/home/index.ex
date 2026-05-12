defmodule UpaTikPortalWeb.Home.Index do
  use UpaTikPortalWeb, :live_view

  # 1. Inisialisasi Data
  @impl true
  def mount(_params, session, socket) do
    user_id = session["user_id"]
    current_user = if user_id, do: UpaTikPortal.Accounts.get_user(user_id), else: nil

    {:ok,
     assign(socket,
       current_user: current_user,
       current_scope: %{user: current_user}
     )}
  end

  # 2. Reaksi Terhadap URL (Live Action)
  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  # 3. Menangani Interaksi User (Event)
  @impl true
  def handle_event("delete", %{"id" => _id}, socket) do
    {:noreply, socket}
  end
end
