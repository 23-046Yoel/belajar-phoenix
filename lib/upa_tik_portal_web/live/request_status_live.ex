defmodule UpaTikPortalWeb.RequestStatusLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = UpaTikPortal.Accounts.get_user!(user_id)
    requests = Requests.list_requests_by_user(user_id)

    {:ok,
     assign(socket,
       page_title: "Status Pengajuan – UPA TIK Portal",
       current_user: user,
       requests: requests
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      <!-- Navbar -->
      <nav class="bg-white border-b border-slate-200 shadow-sm">
        <div class="max-w-5xl mx-auto px-4 h-16 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <div class="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"/>
              </svg>
            </div>
            <span class="font-bold text-slate-800">UPA TIK Portal</span>
          </div>
          <div class="flex items-center gap-4">
            <a href="/portal/ajukan" class="text-sm text-blue-600 hover:text-blue-800 font-medium transition-colors">
              + Ajukan Baru
            </a>
            <a href="/auth/logout" class="text-sm text-slate-500 hover:text-red-600 transition-colors">Logout</a>
          </div>
        </div>
      </nav>

      <div class="max-w-3xl mx-auto px-4 py-10">
        <div class="mb-8">
          <h1 class="text-2xl font-bold text-slate-900">Status Pengajuan Saya</h1>
          <p class="text-slate-500 mt-1">Halo, <strong><%= @current_user.name %></strong> — berikut riwayat pengajuan Anda.</p>
        </div>

        <%= if Enum.empty?(@requests) do %>
          <div class="bg-white rounded-2xl border border-slate-200 p-12 text-center shadow-sm">
            <svg class="w-14 h-14 text-slate-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
            </svg>
            <p class="text-slate-500 font-medium">Belum ada pengajuan</p>
            <a href="/portal/ajukan"
              class="mt-4 inline-block px-5 py-2.5 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700 transition-colors">
              Buat Pengajuan Pertama
            </a>
          </div>
        <% else %>
          <div class="space-y-4">
            <%= for request <- @requests do %>
              <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden hover:shadow-md transition-shadow">
                <div class="p-5 flex items-start justify-between gap-4">
                  <div class="flex-1">
                    <div class="flex items-center gap-2 mb-2">
                      <span class={[
                        "inline-flex px-2.5 py-0.5 rounded-full text-xs font-semibold uppercase",
                        status_class(request.status)
                      ]}>
                        <%= status_label(request.status) %>
                      </span>
                      <span class="text-xs text-slate-400">
                        <%= format_type(request.request_type) %>
                      </span>
                    </div>
                    <p class="font-semibold text-slate-900"><%= request.full_name %></p>
                    <p class="text-sm text-slate-500 mt-0.5">NIM: <%= request.nim %></p>
                    <p class="text-sm text-slate-500">Email: <span class="font-mono"><%= request.email_requested %></span></p>

                    <%= if request.status == "disetujui" && request.otp_code do %>
                      <div class="mt-4 bg-emerald-50 border-2 border-emerald-200 rounded-xl p-5 flex items-center shadow-md relative overflow-hidden">
                        <!-- Decorative pattern -->
                        <div class="absolute right-0 top-0 opacity-10">
                          <svg class="w-32 h-32 -mr-16 -mt-16 text-emerald-600" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 14l9-5-9-5-9 5 9 5z"/>
                          </svg>
                        </div>

                        <div class="w-12 h-12 bg-emerald-600 rounded-full flex items-center justify-center mr-5 shadow-lg relative z-10">
                          <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/>
                          </svg>
                        </div>
                        <div class="relative z-10">
                          <p class="text-[11px] font-black text-emerald-800 uppercase tracking-widest">KODE OTP AKTIVASI ANDA:</p>
                          <p class="font-mono font-black text-black text-4xl tracking-[0.25em] mt-1 drop-shadow-sm" style="color: #000000 !important;">
                            <%= request.otp_code %>
                          </p>
                        </div>
                      </div>
                    <% end %>

                    <%= if request.admin_notes && request.admin_notes != "" do %>
                      <div class="mt-5 bg-white border-l-4 border-blue-500 rounded-lg p-5 shadow-sm border-t border-r border-b border-slate-200">
                        <div class="flex items-center gap-2 mb-2">
                          <span class="p-1 bg-blue-100 rounded text-blue-600">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
                            </svg>
                          </span>
                          <p class="text-xs font-black text-slate-900 uppercase tracking-widest">Catatan Admin UPA TIK:</p>
                        </div>
                        <p class="text-[15px] font-semibold text-black leading-relaxed" style="color: #000000 !important;">
                          <%= request.admin_notes %>
                        </p>
                      </div>
                    <% end %>
                  </div>

                  <div class="text-right text-xs text-slate-400 shrink-0">
                    <%= Calendar.strftime(request.inserted_at, "%d %b %Y") %>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
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
