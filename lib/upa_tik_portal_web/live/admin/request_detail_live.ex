defmodule UpaTikPortalWeb.Admin.RequestDetailLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  def mount(%{"id" => id}, _session, socket) do
    request = Requests.get_request!(id)

    {:ok,
     assign(socket,
       page_title: "Detail Pengajuan – Admin UPA TIK",
       request: request,
       notes: request.admin_notes || "",
       manual_otp: "",
       sending_otp: false,
       otp_sent: false
     )}
  end

  def handle_event("approve", _params, socket) do
    case Requests.update_status(socket.assigns.request, "disetujui", socket.assigns.notes) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(request: updated)
         |> put_flash(:info, "✅ Pengajuan berhasil disetujui.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengupdate status.")}
    end
  end

  def handle_event("reject", _params, socket) do
    case Requests.update_status(socket.assigns.request, "ditolak", socket.assigns.notes) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(request: updated)
         |> put_flash(:info, "❌ Pengajuan ditolak.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengupdate status.")}
    end
  end

  def handle_event("update-field", %{"notes" => notes, "otp" => otp}, socket) do
    {:noreply, assign(socket, notes: notes, manual_otp: otp)}
  end

  def handle_event("update-field", %{"notes" => notes}, socket) do
    {:noreply, assign(socket, notes: notes)}
  end

  def handle_event("update-field", %{"otp" => otp}, socket) do
    {:noreply, assign(socket, manual_otp: otp)}
  end

  def handle_event("send-otp", _params, socket) do
    request = socket.assigns.request

    if request.status != "disetujui" do
      {:noreply, put_flash(socket, :error, "Setujui pengajuan terlebih dahulu sebelum mengirim OTP.")}
    else
      socket = assign(socket, sending_otp: true)
      otp_to_send = if socket.assigns.manual_otp != "", do: socket.assigns.manual_otp, else: nil

      case Requests.send_otp(request, otp_to_send) do
        {:ok, updated} ->
          {:noreply,
           socket
           |> assign(request: updated, sending_otp: false, otp_sent: true, manual_otp: "")
           |> put_flash(:info, "📧 Kode OTP berhasil dikirim ke #{request.email_requested}")}

        {:error, _} ->
          {:noreply,
           socket
           |> assign(sending_otp: false)
           |> put_flash(:error, "Gagal mengirim OTP. Coba lagi.")}
      end
    end
  end

  def handle_event("save-notes", _params, socket) do
    case Requests.update_admin_notes(socket.assigns.request, socket.assigns.notes) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(request: updated)
         |> put_flash(:info, "✅ Catatan berhasil disimpan.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal menyimpan catatan.")}
    end
  end

  def handle_event("delete", _params, socket) do
    case Requests.delete_request(socket.assigns.request) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pengajuan berhasil dihapus.")
         |> push_navigate(to: "/admin/pengajuan")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal menghapus.")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50" data-theme="light">
      <nav class="bg-white border-b border-slate-200 shadow-sm">
        <div class="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <a href="/admin" class="flex items-center gap-2">
              <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center shadow-md">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"/>
                </svg>
              </div>
            </a>
            <span class="text-slate-400">/</span>
            <a href="/admin/pengajuan" class="text-sm text-slate-500 hover:text-blue-600">Pengajuan</a>
            <span class="text-slate-400">/</span>
            <span class="text-sm font-semibold text-slate-800">Detail</span>
          </div>
          <a href="/auth/logout" class="text-sm text-slate-500 hover:text-red-600 transition-colors">Logout</a>
        </div>
      </nav>

      <div class="max-w-4xl mx-auto px-6 py-8">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

          <!-- Main Info -->
          <div class="lg:col-span-2 space-y-4">
            <!-- Identity Card -->
            <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
              <div class="flex items-start justify-between mb-4">
                <h2 class="font-bold text-slate-900 text-lg">Informasi Mahasiswa</h2>
                <span class={"inline-flex px-3 py-1 rounded-full text-sm font-semibold #{status_class(@request.status)}"}>
                  <%= status_label(@request.status) %>
                </span>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-3">
                  <div>
                    <p class="text-xs text-slate-500 uppercase tracking-wide">NIM</p>
                    <p class="font-mono font-semibold text-slate-800"><%= @request.nim %></p>
                  </div>
                  <div>
                    <p class="text-xs text-slate-500 uppercase tracking-wide">Nama Lengkap</p>
                    <p class="font-semibold text-slate-800"><%= @request.full_name %></p>
                  </div>
                </div>
                <div class="space-y-3">
                  <div>
                    <p class="text-xs text-slate-500 uppercase tracking-wide">Email Diminta</p>
                    <p class="font-mono text-sm text-slate-800 break-all"><%= @request.email_requested %></p>
                  </div>
                  <div>
                    <p class="text-xs text-slate-500 uppercase tracking-wide">Jenis Pengajuan</p>
                    <span class="px-2 py-0.5 bg-blue-100 text-blue-700 rounded text-sm font-medium">
                      <%= format_type(@request.request_type) %>
                    </span>
                  </div>
                </div>
              </div>

              <div class="mt-4 pt-4 border-t border-slate-100">
                <p class="text-xs text-slate-500">Diajukan pada: <%= Calendar.strftime(@request.inserted_at, "%d %B %Y, %H:%M") %> WIB</p>
              </div>
            </div>

            <!-- KTM Photo -->
            <%= if @request.ktm_photo_url do %>
              <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
                <h3 class="font-semibold text-slate-800 mb-3">Foto KTM</h3>
                <div class="rounded-xl overflow-hidden border border-slate-200 bg-slate-50">
                  <img src={@request.ktm_photo_url} alt="Foto KTM"
                    class="w-full max-h-72 object-contain"/>
                </div>
                <a href={@request.ktm_photo_url} target="_blank"
                  class="mt-2 inline-flex items-center gap-1 text-xs text-blue-600 hover:underline">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
                  </svg>
                  Buka gambar penuh
                </a>
              </div>
            <% else %>
              <div class="bg-slate-50 rounded-2xl border border-dashed border-slate-300 p-8 text-center">
                <svg class="w-10 h-10 text-slate-300 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                </svg>
                <p class="text-slate-400 text-sm">Foto KTM tidak diunggah</p>
              </div>
            <% end %>

            <!-- OTP Info -->
            <%= if @request.otp_code do %>
              <div class="bg-green-50 rounded-2xl border border-green-200 p-5">
                <p class="text-xs font-semibold text-green-700 uppercase mb-2">Kode OTP Terkirim</p>
                <p class="font-mono text-3xl font-bold text-green-800 tracking-widest"><%= @request.otp_code %></p>
                <p class="text-xs text-green-600 mt-1">
                  Dikirim: <%= Calendar.strftime(@request.otp_sent_at, "%d %B %Y, %H:%M") %> WIB
                </p>
              </div>
            <% end %>
          </div>

            <!-- Action Panel Wrapper -->
            <div class="space-y-4">
              <.form for={%{}} phx-change="update-field" class="space-y-4">
                <!-- Notes -->
                <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-5">
                  <h3 class="font-semibold text-slate-800 mb-3">Catatan Admin</h3>
                  <textarea
                    name="notes"
                    rows="4"
                    placeholder="Tambahkan catatan untuk mahasiswa..."
                    class="w-full p-3 border border-slate-200 rounded-xl text-sm resize-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
                    style="color: #000000 !important; background-color: #ffffff !important; -webkit-text-fill-color: #000000 !important; font-weight: 500; border: 1px solid #cbd5e1;"
                  ><%= @notes %></textarea>
                  <button
                    type="button"
                    phx-click="save-notes"
                    class="mt-3 w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm rounded-xl shadow-md transition-all flex items-center justify-center gap-2 active:scale-[0.98]">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4"/>
                    </svg>
                    SIMPAN CATATAN ADMIN
                  </button>
                </div>

                <!-- Manual OTP -->
                <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-5">
                  <h3 class="font-semibold text-slate-800 mb-1">Input OTP Manual</h3>
                  <p class="text-xs text-slate-500 mb-3">Kosongkan jika ingin kode otomatis</p>
                  <input
                    type="text"
                    name="otp"
                    value={@manual_otp}
                    placeholder="Contoh: 123456"
                    maxlength="6"
                    class="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all"
                    style="color: #000000 !important; background-color: #ffffff !important; -webkit-text-fill-color: #000000 !important; font-weight: 700; letter-spacing: 0.1em;"
                  />

                  <!-- Send OTP Button (Moved here) -->
                  <button phx-click="send-otp" disabled={@sending_otp or @request.status != "disetujui"}
                    class={[
                      "mt-4 w-full py-3 rounded-xl font-bold text-sm transition-all flex items-center justify-center gap-2",
                      if(@request.status == "disetujui",
                        do: "bg-indigo-600 hover:bg-indigo-700 text-white shadow-md active:scale-[0.98]",
                        else: "bg-slate-100 text-slate-400 cursor-not-allowed"
                      )
                    ]}>
                    <%= if @sending_otp do %>
                      <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
                      </svg>
                      Mengirim...
                    <% else %>
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/>
                      </svg>
                      KIRIM KODE OTP SEKARANG
                    <% end %>
                  </button>
                  <%= if @request.status != "disetujui" do %>
                    <p class="text-[10px] text-red-500 mt-2 font-medium text-center">⚠ Setujui pengajuan untuk mengirim OTP</p>
                  <% end %>
                </div>
              </.form>

              <!-- Action Buttons (Independent) -->
              <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-5 space-y-3">
                <h3 class="font-semibold text-slate-800 mb-1">Tindakan</h3>

                <!-- Approve -->
                <button phx-click="approve"
                  class={[
                    "w-full py-2.5 rounded-xl font-semibold text-sm transition-all flex items-center justify-center gap-2",
                    if(@request.status == "disetujui",
                      do: "bg-green-100 text-green-700 cursor-default",
                      else: "bg-green-600 hover:bg-green-700 text-white shadow-md hover:shadow-lg"
                    )
                  ]}>
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  <%= if @request.status == "disetujui", do: "Sudah Disetujui", else: "Setujui" %>
                </button>

                <!-- Reject -->
                <button phx-click="reject"
                  class={[
                    "w-full py-2.5 rounded-xl font-semibold text-sm transition-all flex items-center justify-center gap-2",
                    if(@request.status == "ditolak",
                      do: "bg-red-100 text-red-700 cursor-default",
                      else: "bg-red-600 hover:bg-red-700 text-white shadow-md hover:shadow-lg"
                    )
                  ]}>
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                  </svg>
                  <%= if @request.status == "ditolak", do: "Sudah Ditolak", else: "Tolak" %>
                </button>

                <!-- Send OTP (Removed from here) -->

                <div class="pt-1 border-t border-slate-100">
                  <!-- Delete -->
                  <button phx-click="delete"
                    data-confirm="Yakin ingin menghapus pengajuan ini secara permanen?"
                    class="w-full py-2 text-red-600 hover:text-red-800 text-sm font-medium transition-colors">
                    🗑 Hapus Pengajuan
                  </button>
                </div>
              </div>
            </div>

              <!-- Back -->
              <a href="/admin/pengajuan"
                class="flex items-center gap-2 text-sm text-slate-500 hover:text-slate-700 transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
                </svg>
                Kembali ke Daftar
            </a>
          </div>
        </div>
      </div>
    """
  end

  defp status_class("pending"), do: "bg-amber-100 text-amber-800"
  defp status_class("disetujui"), do: "bg-green-100 text-green-800"
  defp status_class("ditolak"), do: "bg-red-100 text-red-800"
  defp status_class(_), do: "bg-slate-100 text-slate-800"

  defp status_label("pending"), do: "⏳ Menunggu"
  defp status_label("disetujui"), do: "✅ Disetujui"
  defp status_label("ditolak"), do: "❌ Ditolak"
  defp status_label(s), do: s

  defp format_type("aktivasi"), do: "Aktivasi Akun"
  defp format_type("reset"), do: "Reset Password"
  defp format_type(t), do: t
end
