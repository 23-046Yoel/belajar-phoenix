defmodule UpaTikPortalWeb.Home.Lowongan.Index do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipOpeningService

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    lowongans = InternshipOpeningService.list_internship_openings(is_active: true)
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:page_title, "Cari Lowongan Magang")
     |> assign(:any_lowongan?, lowongans != [])
     |> assign(:user, user)
     |> stream(:lowongans, lowongans)}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    # Implementasi pencarian sederhana
    lowongans = InternshipOpeningService.list_internship_openings(is_active: true, search: query)

    {:noreply,
     socket
     |> assign(:any_lowongan?, lowongans != [])
     |> stream(:lowongans, lowongans, reset: true)}
  end
end
