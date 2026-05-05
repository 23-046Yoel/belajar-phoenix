defmodule UpaTikPortalWeb.Home.Lowongan.Detail do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipOpeningService

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # Ambil data lowongan berdasarkan ID
    opening = InternshipOpeningService.get_internship_opening!(id)

    {:ok,
     socket
     |> assign(:page_title, opening.title)
     |> assign(:opening, opening)
     |> assign(:has_applied, false)} # Nanti ini dihubungkan dengan data user yang login
  end

  @impl true
  def handle_event("ajukan_magang", _params, socket) do
    # Logika Pengajuan Magang
    # Karena kita belum punya tabel 'Applications/Pendaftar',
    # kita buat simulasi dengan mengubah state 'has_applied' sementara.

    # Nanti di sini kamu panggil fungsi seperti:
    # Recruitment.create_application(%{user_id: user.id, opening_id: opening.id})

    {:noreply,
     socket
     |> put_flash(:info, "Pengajuan magang berhasil dikirim! Silakan cek status Anda secara berkala.")}
  end
end
