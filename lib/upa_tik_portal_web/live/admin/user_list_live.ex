defmodule UpaTikPortalWeb.Admin.UserListLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Accounts

  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    {:ok, assign(socket, users: users, page_title: "Daftar Pengguna – UPA TIK Admin")}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50">
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
            <span class="text-sm font-semibold text-slate-800">Daftar Pengguna</span>
          </div>
          <div class="flex items-center gap-4">
             <a href="/admin/pengajuan" class="text-sm font-medium text-slate-500 hover:text-blue-600 transition-colors">Pengajuan</a>
             <a href="/auth/logout" class="text-sm text-slate-500 hover:text-red-600 transition-colors">Logout</a>
          </div>
        </div>
      </nav>

      <div class="max-w-7xl mx-auto px-6 py-8">
        <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-200">
                <th class="px-6 py-4 text-xs font-bold text-slate-500 uppercase">Nama</th>
                <th class="px-6 py-4 text-xs font-bold text-slate-500 uppercase">Email</th>
                <th class="px-6 py-4 text-xs font-bold text-slate-500 uppercase">Role</th>
                <th class="px-6 py-4 text-xs font-bold text-slate-500 uppercase">Login Terakhir</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <%= for user <- @users do %>
                <tr class="hover:bg-slate-50/50 transition-colors">
                  <td class="px-6 py-4">
                    <p class="font-semibold text-slate-800 text-sm"><%= user.name %></p>
                  </td>
                  <td class="px-6 py-4">
                    <p class="text-slate-600 text-sm font-mono"><%= user.email %></p>
                  </td>
                  <td class="px-6 py-4">
                    <span class={"px-2.5 py-1 rounded-lg text-xs font-bold #{role_class(user.role)}"}>
                      <%= String.upcase(user.role) %>
                    </span>
                  </td>
                  <td class="px-6 py-4 text-sm text-slate-500">
                    <%= Calendar.strftime(user.updated_at, "%d %b %Y, %H:%M") %>
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

  defp role_class("admin"), do: "bg-purple-100 text-purple-700"
  defp role_class(_), do: "bg-blue-100 text-blue-700"
end
