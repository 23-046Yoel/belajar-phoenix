defmodule UpaTikPortalWeb.Admin.RequestListLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  def mount(_params, _session, socket) do
    requests = Requests.list_requests()

    {:ok,
     assign(socket,
       page_title: "Pengajuan – Admin UPA TIK",
       requests: requests,
       filter: "all",
       search: ""
     )}
  end

  def handle_event("filter", %{"status" => status}, socket) do
    {:noreply, assign(socket, filter: status)}
  end

  def handle_event("search", %{"q" => q}, socket) do
    {:noreply, assign(socket, search: String.downcase(q))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    request = Requests.get_request!(id)

    case Requests.delete_request(request) do
      {:ok, _} ->
        requests = Requests.list_requests()

        {:noreply,
         socket
         |> assign(requests: requests)
         |> put_flash(:info, "Pengajuan berhasil dihapus.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal menghapus pengajuan.")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50">
      <%!-- <nav class="bg-white border-b border-slate-200 shadow-sm">
        <div class="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <a href="/admin" class="flex items-center gap-2">
              <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center shadow-md">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"/>
                </svg>
              </div>
              <div>
                <p class="font-bold text-slate-900 text-sm leading-none">UPA TIK Admin</p>
                <p class="text-xs text-slate-500">Panel Manajemen</p>
              </div>
            </a>
          </div>
          <div class="flex gap-4 items-center">
            <a href="/admin" class="text-sm text-slate-500 hover:text-slate-800">Dashboard</a>
            <a href="/auth/logout" class="text-sm text-slate-500 hover:text-red-600 transition-colors">Logout</a>
          </div>
        </div>
      </nav> --%>
      <.navbarAdmin active_tab={:pengajuan} />

      <div class="max-w-7xl mx-auto px-6 py-8">
        <div class="mb-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 class="text-2xl font-bold text-slate-900">Daftar Pengajuan</h1>
            <p class="text-slate-500 text-sm"><%= length(@requests) %> total pengajuan</p>
          </div>

          <!-- Search -->
          <div class="relative">
            <input type="text" placeholder="Cari NIM atau nama..."
              phx-keyup="search" phx-value-q=""
              class="pl-9 pr-4 py-2 border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white w-64"
              value={@search} name="q"/>
            <svg class="w-4 h-4 text-slate-400 absolute left-2.5 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
            </svg>
          </div>
        </div>

        <!-- Filter Tabs -->
        <div class="flex gap-2 mb-4 flex-wrap">
          <%= for {label, val} <- [{"Semua", "all"}, {"Menunggu", "pending"}, {"Disetujui", "disetujui"}, {"Ditolak", "ditolak"}] do %>
            <button phx-click="filter" phx-value-status={val}
              class={[
                "px-4 py-1.5 rounded-full text-sm font-medium transition-all",
                if(@filter == val, do: "bg-blue-600 text-white shadow-md", else: "bg-white border border-slate-200 text-slate-600 hover:border-blue-300")
              ]}>
              <%= label %>
            </button>
          <% end %>
        </div>

        <!-- Table -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <table class="w-full text-sm">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-200">
                <th class="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Nama / NIM</th>
                <th class="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Email Diminta</th>
                <th class="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Jenis</th>
                <th class="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Status</th>
                <th class="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Tanggal</th>
                <th class="text-center px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <%= for request <- filtered_requests(@requests, @filter, @search) do %>
                <tr class="hover:bg-blue-50/40 transition-colors">
                  <td class="px-4 py-3">
                    <p class="font-semibold text-slate-800"><%= request.full_name %></p>
                    <p class="text-xs text-slate-500 font-mono"><%= request.nim %></p>
                  </td>
                  <td class="px-4 py-3 font-mono text-xs text-slate-600"><%= request.email_requested %></td>
                  <td class="px-4 py-3">
                    <span class="px-2 py-0.5 bg-blue-100 text-blue-700 rounded-md text-xs font-medium">
                      <%= format_type(request.request_type) %>
                    </span>
                  </td>
                  <td class="px-4 py-3">
                    <span class={"inline-flex px-2.5 py-0.5 rounded-full text-xs font-semibold #{status_class(request.status)}"}>
                      <%= status_label(request.status) %>
                    </span>
                  </td>
                  <td class="px-4 py-3 text-xs text-slate-500">
                    <%= Calendar.strftime(request.inserted_at, "%d %b %Y") %>
                  </td>
                  <td class="px-4 py-3">
                    <div class="flex items-center justify-center gap-2">
                      <a href={"/admin/pengajuan/#{request.id}"}
                        class="px-3 py-1.5 bg-blue-600 text-white text-xs rounded-lg hover:bg-blue-700 transition-colors font-medium">
                        Detail
                      </a>
                      <button phx-click="delete" phx-value-id={request.id}
                        data-confirm="Yakin ingin menghapus pengajuan ini?"
                        class="px-3 py-1.5 bg-red-100 text-red-700 text-xs rounded-lg hover:bg-red-200 transition-colors font-medium">
                        Hapus
                      </button>
                    </div>
                  </td>
                </tr>
              <% end %>
              <%= if Enum.empty?(filtered_requests(@requests, @filter, @search)) do %>
                <tr>
                  <td colspan="6" class="px-4 py-10 text-center text-slate-400">Tidak ada pengajuan ditemukan</td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  defp filtered_requests(requests, filter, search) do
    requests
    |> Enum.filter(fn r ->
      (filter == "all" || r.status == filter) &&
        (search == "" ||
           String.contains?(String.downcase(r.nim), search) ||
           String.contains?(String.downcase(r.full_name), search))
    end)
  end

  defp status_class("pending"), do: "bg-amber-100 text-amber-800"
  defp status_class("disetujui"), do: "bg-green-100 text-green-800"
  defp status_class("ditolak"), do: "bg-red-100 text-red-800"
  defp status_class(_), do: "bg-slate-100 text-slate-800"

  defp status_label("pending"), do: "Menunggu"
  defp status_label("disetujui"), do: "Disetujui"
  defp status_label("ditolak"), do: "Ditolak"
  defp status_label(s), do: s

  defp format_type("aktivasi"), do: "Aktivasi"
  defp format_type("reset"), do: "Reset"
  defp format_type(t), do: t
end
