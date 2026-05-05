defmodule UpaTikPortalWeb.Home.Lowongan.Index do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipOpeningService

  @impl true
  def mount(_params, _session, socket) do
    # Mengambil lowongan yang aktif saja
    lowongans = InternshipOpeningService.list_internship_openings(is_active: true)

    {:ok,
     socket
     |> assign(:page_title, "Cari Lowongan Magang")
     |> assign(:any_lowongan?, lowongans != [])
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
