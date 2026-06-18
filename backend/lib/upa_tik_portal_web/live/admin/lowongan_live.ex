defmodule UpaTikPortalWeb.Admin.LowonganLive do
  use UpaTikPortalWeb, :live_view
  # alias UpaTikPortal.Recruitment

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # @impl true
  # def handle_event("delete", %{"id" => id}, socket) do
  #   opening = Recruitment.get_internship_opening!(id)
  #   {:ok, _} = Recruitment.delete_internship_opening(opening)

  #   # Menghapus baris dari tabel secara instan tanpa reload halaman
  #   {:noreply, stream_delete(socket, :internship_openings, opening)}
  # end
end
