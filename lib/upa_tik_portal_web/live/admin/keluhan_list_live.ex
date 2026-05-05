defmodule UpaTikPortalWeb.Admin.KeluhanListLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Keluhans

  def mount(_params, _session, socket) do
    keluhans = Keluhans.list_keluhans()
    stats = Keluhans.stats()

    {:ok,
     assign(socket,
       page_title: "Keluhan – Admin UPA TIK",
       keluhans: keluhans,
       baru: Map.get(stats, "baru", 0),
       diproses: Map.get(stats, "diproses", 0),
       selesai: Map.get(stats, "selesai", 0),
       selected_id: nil,
       selected_keluhan: nil,
       admin_notes: ""
     )}
  end

  def handle_event("select", %{"id" => id}, socket) do
    keluhan = Keluhans.get_keluhan!(id)

    {:noreply,
     assign(socket,
       selected_id: id,
       selected_keluhan: keluhan,
       admin_notes: keluhan.admin_notes || ""
     )}
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, selected_id: nil, selected_keluhan: nil)}
  end

  def handle_event("update_status", %{"status" => status}, socket) do
    keluhan = socket.assigns.selected_keluhan

    case Keluhans.update_keluhan_status(keluhan, %{
           "status" => status,
           "admin_notes" => socket.assigns.admin_notes
         }) do
      {:ok, _updated} ->
        keluhans = Keluhans.list_keluhans()
        stats = Keluhans.stats()

        {:noreply,
         socket
         |> assign(keluhans: keluhans)
         |> assign(baru: Map.get(stats, "baru", 0))
         |> assign(diproses: Map.get(stats, "diproses", 0))
         |> assign(selesai: Map.get(stats, "selesai", 0))
         |> assign(selected_id: nil, selected_keluhan: nil)
         |> put_flash(:info, "Status keluhan berhasil diperbarui.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal memperbarui status.")}
    end
  end

  def handle_event("update_notes", %{"admin_notes" => notes}, socket) do
    {:noreply, assign(socket, admin_notes: notes)}
  end

  defp status_badge("baru"), do: {"bg-blue-100 text-blue-700 border border-blue-200", "🆕 Baru"}
  defp status_badge("diproses"), do: {"bg-amber-100 text-amber-700 border border-amber-200", "⏳ Diproses"}
  defp status_badge("selesai"), do: {"bg-green-100 text-green-700 border border-green-200", "✅ Selesai"}
  defp status_badge(_), do: {"bg-slate-100 text-slate-700", "Unknown"}

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50">
      <%!-- Admin Navbar --%>
      <.navbarAdmin active_tab={:keluhan} />

      <div class="max-w-7xl mx-auto px-6 py-8">
        <%!-- Header --%>
        <div class="mb-6">
          <h1 class="text-2xl font-bold text-slate-900">Manajemen Keluhan</h1>
          <p class="text-slate-500 mt-1">Tinjau dan tanggapi keluhan dari mahasiswa</p>
        </div>

        <%!-- Stats --%>
        <div class="grid grid-cols-3 gap-4 mb-8">
          <div class="bg-blue-50 rounded-2xl border border-blue-200 p-5">
            <p class="text-xs font-semibold uppercase tracking-wide text-blue-600">Baru</p>
            <p class="text-4xl font-bold text-blue-700 mt-1"><%= @baru %></p>
            <p class="text-xs text-blue-400 mt-1">Perlu ditindaklanjuti</p>
          </div>
          <div class="bg-amber-50 rounded-2xl border border-amber-200 p-5">
            <p class="text-xs font-semibold uppercase tracking-wide text-amber-600">Diproses</p>
            <p class="text-4xl font-bold text-amber-700 mt-1"><%= @diproses %></p>
            <p class="text-xs text-amber-400 mt-1">Sedang ditangani</p>
          </div>
          <div class="bg-green-50 rounded-2xl border border-green-200 p-5">
            <p class="text-xs font-semibold uppercase tracking-wide text-green-600">Selesai</p>
            <p class="text-4xl font-bold text-green-700 mt-1"><%= @selesai %></p>
            <p class="text-xs text-green-400 mt-1">Telah diselesaikan</p>
          </div>
        </div>

        <%!-- Keluhan Table --%>
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
          <div class="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
            <h2 class="font-semibold text-slate-800">Semua Keluhan</h2>
            <span class="text-xs text-slate-400"><%= length(@keluhans) %> total</span>
          </div>

          <%= if Enum.empty?(@keluhans) do %>
            <div class="px-6 py-16 text-center text-slate-400">
              <svg class="w-12 h-12 mx-auto mb-3 text-slate-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
              </svg>
              <p class="text-sm">Belum ada keluhan yang masuk.</p>
            </div>
          <% else %>
            <table class="w-full text-sm">
              <thead>
                <tr class="bg-slate-50 border-b border-slate-100">
                  <th class="text-left px-6 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Pengguna</th>
                  <th class="text-left px-6 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Judul Keluhan</th>
                  <th class="text-left px-6 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Tanggal</th>
                  <th class="text-left px-6 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Status</th>
                  <th class="text-left px-6 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Aksi</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-100">
                <%= for keluhan <- @keluhans do %>
                  <% {badge_class, badge_text} = status_badge(keluhan.status) %>
                  <tr class={["hover:bg-slate-50 transition-colors", if(@selected_id == keluhan.id, do: "bg-blue-50", else: "")]}>
                    <td class="px-6 py-4">
                      <p class="font-medium text-slate-800"><%= keluhan.user.name %></p>
                      <p class="text-xs text-slate-400"><%= keluhan.user.email %></p>
                    </td>
                    <td class="px-6 py-4">
                      <p class="text-slate-800 font-medium truncate max-w-xs"><%= keluhan.subject %></p>
                      <p class="text-xs text-slate-400 mt-0.5 truncate max-w-xs"><%= keluhan.description %></p>
                    </td>
                    <td class="px-6 py-4 text-xs text-slate-500">
                      <%= Calendar.strftime(keluhan.inserted_at, "%d %b %Y\n%H:%M") %>
                    </td>
                    <td class="px-6 py-4">
                      <span class={"text-xs font-semibold px-2.5 py-1 rounded-full #{badge_class}"}>
                        <%= badge_text %>
                      </span>
                    </td>
                    <td class="px-6 py-4">
                      <button phx-click="select" phx-value-id={keluhan.id}
                        class="text-xs font-medium text-blue-600 hover:text-blue-800 hover:underline transition-colors">
                        Tinjau
                      </button>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          <% end %>
        </div>
      </div>

      <%!-- Detail Modal --%>
      <%= if @selected_keluhan do %>
        <div class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4" phx-click="close">
          <div class="bg-white rounded-2xl shadow-2xl w-full max-w-lg" phx-click-away="close" phx-click={nil}>
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
              <h3 class="font-bold text-slate-900">Detail Keluhan</h3>
              <button phx-click="close" class="text-slate-400 hover:text-slate-600 transition-colors">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
              </button>
            </div>
            <div class="px-6 py-5 space-y-4">
              <div>
                <p class="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-1">Pengirim</p>
                <p class="text-sm font-medium text-slate-800"><%= @selected_keluhan.user.name %></p>
                <p class="text-xs text-slate-500"><%= @selected_keluhan.user.email %></p>
              </div>
              <div>
                <p class="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-1">Judul</p>
                <p class="text-sm font-medium text-slate-800"><%= @selected_keluhan.subject %></p>
              </div>
              <div>
                <p class="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-1">Isi Keluhan</p>
                <p class="text-sm text-slate-700 leading-relaxed whitespace-pre-wrap"><%= @selected_keluhan.description %></p>
              </div>
              <div>
                <label class="text-xs font-semibold text-slate-500 uppercase tracking-wide block mb-1">Catatan Admin (Opsional)</label>
                <textarea
                  phx-change="update_notes"
                  name="admin_notes"
                  rows="3"
                  placeholder="Tambahkan catatan atau tanggapan untuk pengguna..."
                  class="w-full px-3 py-2 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 outline-none resize-none text-slate-800"
                ><%= @admin_notes %></textarea>
              </div>
              <div>
                <p class="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-2">Ubah Status</p>
                <div class="flex gap-2">
                  <button phx-click="update_status" phx-value-status="baru"
                    class="flex-1 py-2 text-xs font-semibold rounded-xl bg-blue-100 text-blue-700 hover:bg-blue-200 transition-colors border border-blue-200">
                    🆕 Baru
                  </button>
                  <button phx-click="update_status" phx-value-status="diproses"
                    class="flex-1 py-2 text-xs font-semibold rounded-xl bg-amber-100 text-amber-700 hover:bg-amber-200 transition-colors border border-amber-200">
                    ⏳ Diproses
                  </button>
                  <button phx-click="update_status" phx-value-status="selesai"
                    class="flex-1 py-2 text-xs font-semibold rounded-xl bg-green-100 text-green-700 hover:bg-green-200 transition-colors border border-green-200">
                    ✅ Selesai
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
