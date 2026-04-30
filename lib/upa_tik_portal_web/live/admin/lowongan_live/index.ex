defmodule UpaTikPortalWeb.Admin.LowonganLive.Index do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment
  alias UpaTikPortal.Recruitment.InternshipOpening
  alias UpaTikPortalWeb.Admin.LowonganLive.FormComponent

  @impl true
  def mount(_params, _session, socket) do
    lowongans = Recruitment.list_internship_openings()
    IO.inspect(lowongans, label: "Anj")
    {:ok,
      socket
      |> assign(:any_lowongan?, lowongans != [])
      |> stream(:lowongans, lowongans)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Lowongan")
    |> assign(:opening, Recruitment.get_internship_opening!(id))
  end

  def apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Tambah Lowongan Baru")
    |> assign(:opening, %InternshipOpening{})
  end

  def apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Daftar Lowongan")
    |> assign(:opening, nil)
  end

  @impl true
  def handle_info({FormComponent, {:saved, opening}}, socket) do
    # Update stream agar data baru langsung muncul di tabel tanpa refresh
    {:noreply, stream_insert(socket, :lowongans, opening, at: 0)}
  end
end
