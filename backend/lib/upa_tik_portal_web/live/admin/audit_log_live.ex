defmodule UpaTikPortalWeb.Admin.AuditLogLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.AuditLogs

  @impl true
  def mount(_params, _session, socket) do
    logs = AuditLogs.list_audit_logs()

    {:ok,
     assign(socket,
       page_title: "Log Aktivitas Admin – UPA TIK Admin",
       logs: logs,
       filtered_logs: logs,
       search_query: ""
     )}
  end

  @impl true
  def handle_event("search", %{"search_query" => query}, socket) do
    q = String.trim(query) |> String.downcase()

    filtered =
      if q == "" do
        socket.assigns.logs
      else
        Enum.filter(socket.assigns.logs, fn log ->
          action_match = String.contains?(String.downcase(log.action), q)
          details_match = log.details && String.contains?(String.downcase(log.details), q)
          actor_name_match = String.contains?(String.downcase(log.actor.name), q)
          actor_email_match = String.contains?(String.downcase(log.actor.email), q)

          action_match || details_match || actor_name_match || actor_email_match
        end)
      end

    {:noreply, assign(socket, filtered_logs: filtered, search_query: query)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <nav class="sticky top-4 z-50 bg-white/80 backdrop-blur-md shadow-sm border border-slate-200/60 transition-all mb-8 rounded-2xl mx-auto max-w-5xl px-4 sm:px-6">
      <div class="flex justify-between h-16">
        <div class="flex items-center gap-3">
          <div class="p-1 bg-white rounded-xl shadow-sm border border-slate-100 flex items-center justify-center">
            <img
              src={~p"/images/utm_logo.png"}
              class="h-8 w-auto hover:scale-105 transition-transform drop-shadow-sm"
              alt="UTM Logo"
            />
          </div>

          <span class="text-slate-900 font-extrabold text-lg tracking-tight uppercase italic">
            Admin <span class="text-indigo-600">Console</span>
          </span>
        </div>

        <div class="flex items-center space-x-1 sm:space-x-4">
          <a
            href="/admin"
            class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all"
          >
            Overview
          </a>
          <a
            href="/admin/pengajuan"
            class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all"
          >
            Pengajuan
          </a>
          <a
            href="/admin/keluhan"
            class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all"
          >
            Keluhan
          </a>
          <a
            href="/admin/users"
            class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all text-xs uppercase"
          >
            Users
          </a>
          <a
            href="/admin/logs"
            class="px-4 py-2 rounded-xl text-indigo-600 bg-indigo-50 font-bold text-sm transition-all text-xs uppercase"
          >
            Logs
          </a>
          <div class="w-px h-6 bg-slate-200 mx-1 hidden sm:block"></div>

          <a href="/auth/logout" class="p-2 text-slate-400 hover:text-rose-500 transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
              />
            </svg>
          </a>
        </div>
      </div>
    </nav>

    <div class="space-y-8 max-w-5xl mx-auto pb-20">
      <div class="flex flex-col md:flex-row justify-between items-center bg-white p-8 rounded-[2rem] shadow-xl shadow-slate-200/50 border border-slate-100 gap-6">
        <div class="space-y-1">
          <h1 class="text-3xl font-black text-slate-900 tracking-tight uppercase italic">
            Log <span class="text-indigo-600">Aktivitas</span>
          </h1>

          <p class="text-slate-400 font-bold text-xs uppercase tracking-[0.2em] italic">
            Audit Trail Tindakan Administratif
          </p>
        </div>

        <div class="flex items-center gap-4 w-full md:w-auto">
          <form phx-change="search" class="w-full relative" onSubmit="return false;">
            <input
              type="text"
              name="search_query"
              value={@search_query}
              placeholder="Cari log atau nama admin..."
              class="w-full md:w-80 pl-12 pr-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-4 focus:ring-indigo-50 focus:border-indigo-500 focus:bg-white outline-none transition-all font-bold text-slate-900 shadow-inner text-sm"
            />
            <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-slate-400">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2.5"
                  d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                />
              </svg>
            </div>
          </form>
        </div>
      </div>

      <div class="bg-white rounded-[2.5rem] shadow-2xl shadow-slate-200/50 border border-slate-100 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead class="bg-slate-50/50 border-b border-slate-100">
              <tr>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">
                  Waktu
                </th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">
                  Aktor (Admin)
                </th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">
                  Tindakan / Aksi
                </th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">
                  Rincian Deskripsi
                </th>
              </tr>
            </thead>

            <tbody class="divide-y divide-slate-50">
              <%= for log <- @filtered_logs do %>
                <tr class="hover:bg-slate-50/30 transition-all cursor-default">
                  <td class="px-10 py-6 whitespace-nowrap text-xs font-mono text-slate-400">
                    {Calendar.strftime(log.inserted_at, "%d %b %Y %H:%M:%S")}
                  </td>

                  <td class="px-10 py-6">
                    <div class="flex items-center gap-3">
                      <div class="w-8 h-8 bg-indigo-50 text-indigo-600 rounded-lg flex items-center justify-center font-black text-xs italic border border-indigo-100">
                        {String.at(log.actor.name, 0)}
                      </div>
                      <div>
                        <p class="font-black text-slate-900 text-sm tracking-tight uppercase">
                          {log.actor.name}
                        </p>
                        <p class="text-[9px] text-slate-400 font-mono">
                          {log.actor.email}
                        </p>
                      </div>
                    </div>
                  </td>

                  <td class="px-10 py-6 whitespace-nowrap">
                    <span class={[
                      "px-3 py-1 rounded-lg text-[9px] font-black uppercase tracking-widest shadow-sm border",
                      action_badge_class(log.action)
                    ]}>
                      {action_label(log.action)}
                    </span>
                  </td>

                  <td class="px-10 py-6 text-sm text-slate-600 font-medium leading-relaxed max-w-xs md:max-w-md break-words">
                    {log.details}
                  </td>
                </tr>
              <% end %>

              <%= if Enum.empty?(@filtered_logs) do %>
                <tr>
                  <td colspan="4" class="p-20 text-center bg-slate-50/20">
                    <div class="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center mx-auto mb-4 text-slate-300 border border-slate-100">
                      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
                        />
                      </svg>
                    </div>
                    <p class="text-xs font-black text-slate-300 uppercase tracking-widest italic">
                      Tidak ada data log audit ditemukan
                    </p>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  defp action_badge_class("approve_request"),
    do: "bg-emerald-50 text-emerald-700 border-emerald-100"

  defp action_badge_class("reject_request"), do: "bg-rose-50 text-rose-700 border-rose-100"
  defp action_badge_class("send_credentials"), do: "bg-teal-50 text-teal-700 border-teal-100"
  defp action_badge_class("update_notes"), do: "bg-amber-50 text-amber-700 border-amber-100"

  defp action_badge_class("change_complaint_status"),
    do: "bg-indigo-50 text-indigo-700 border-indigo-100"

  defp action_badge_class("send_complaint_message"), do: "bg-sky-50 text-sky-700 border-sky-100"
  defp action_badge_class(_), do: "bg-slate-50 text-slate-700 border-slate-100"

  defp action_label("approve_request"), do: "✅ Setujui Akun"
  defp action_label("reject_request"), do: "❌ Tolak Akun"
  defp action_label("send_credentials"), do: "📧 Kirim Creds"
  defp action_label("update_notes"), do: "📝 Catat Admin"
  defp action_label("change_complaint_status"), do: "⏳ Status Kendala"
  defp action_label("send_complaint_message"), do: "💬 Balas Chat"
  defp action_label(act), do: act
end
