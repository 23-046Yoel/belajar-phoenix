defmodule UpaTikPortalWeb.Admin.DashboardLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  def mount(_params, _session, socket) do
    stats = Requests.stats()
    keluhan_stats = UpaTikPortal.Keluhans.stats()

    {:ok,
     assign(socket,
       page_title: "Dashboard Admin – UPA TIK Portal",
       pending: Map.get(stats, "pending", 0),
       disetujui: Map.get(stats, "disetujui", 0),
       ditolak: Map.get(stats, "ditolak", 0),
       total: Enum.sum(Map.values(stats)),
       keluhan_baru: Map.get(keluhan_stats, "baru", 0)
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50 shadow-inner">
      <nav class="bg-indigo-700 shadow-lg border-b border-indigo-800">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between h-16">
            <div class="flex items-center">
              <div class="flex-shrink-0 flex items-center gap-3">
                <div class="bg-white p-1 rounded">
                  <img src={~p"/images/utm_logo.png"} class="h-6 w-auto" alt="UTM Logo">
                </div>
                <span class="text-white font-bold text-lg tracking-tight">UPA TIK Admin</span>
              </div>
              <div class="hidden md:block">
                <div class="ml-10 flex items-baseline space-x-4">
                  <a href="/admin" class="bg-indigo-900 text-white px-3 py-2 rounded-md text-sm font-medium">Dashboard</a>
                  <a href="/admin/pengajuan" class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium">Pengajuan</a>
                  <a href="/admin/keluhan" class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium">Keluhan</a>
                  <a href="/admin/users" class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium">Pengguna</a>
                </div>
              </div>
            </div>
            <div class="hidden md:block">
              <div class="ml-4 flex items-center md:ml-6">
                <a href="/auth/logout" class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors flex gap-2 items-center">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                  Keluar
                </a>
              </div>
            </div>
          </div>
        </div>
      </nav>

      <header class="bg-white shadow-sm border-b border-slate-200">
        <div class="max-w-7xl mx-auto py-4 px-4 sm:px-6 lg:px-8 flex justify-between items-center">
          <h1 class="text-2xl font-bold text-slate-800">
            Dashboard
          </h1>
          <p class="text-sm text-slate-500"><%= Calendar.strftime(DateTime.utc_now(), "%d %B %Y") %></p>
        </div>
      </header>

      <main>
        <div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
          <div class="px-4 py-6 sm:px-0">

            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
              <div class="bg-white rounded-lg shadow p-6 border border-slate-100 flex items-center">
                <div class="p-3 rounded-full bg-slate-100 text-slate-600 mr-4">
                  <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path d="M7 3a1 1 0 000 2h6a1 1 0 100-2H7zM4 7a1 1 0 011-1h10a1 1 0 110 2H5a1 1 0 01-1-1zM2 11a2 2 0 012-2h12a2 2 0 012 2v4a2 2 0 01-2 2H4a2 2 0 01-2-2v-4z"/></svg>
                </div>
                <div>
                  <p class="text-sm font-medium text-slate-500 mb-1">Total Laporan</p>
                  <p class="text-3xl font-bold text-slate-900"><%= @total %></p>
                </div>
              </div>

              <div class="bg-white rounded-lg shadow p-6 border border-slate-100 flex items-center">
                <div class="p-3 rounded-full bg-amber-50 text-amber-600 mr-4">
                  <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/></svg>
                </div>
                <div>
                  <p class="text-sm font-medium text-slate-500 mb-1">Pengajuan Menunggu</p>
                  <p class="text-3xl font-bold text-amber-600"><%= @pending %></p>
                </div>
              </div>

              <div class="bg-white rounded-lg shadow p-6 border border-slate-100 flex items-center">
                <div class="p-3 rounded-full bg-rose-50 text-rose-600 mr-4">
                  <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/></svg>
                </div>
                <div>
                  <p class="text-sm font-medium text-slate-500 mb-1">Keluhan Baru</p>
                  <p class="text-3xl font-bold text-rose-600"><%= @keluhan_baru %></p>
                </div>
              </div>

              <div class="bg-white rounded-lg shadow p-6 border border-slate-100 flex items-center">
                <div class="p-3 rounded-full bg-emerald-50 text-emerald-600 mr-4">
                  <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/></svg>
                </div>
                <div>
                  <p class="text-sm font-medium text-slate-500 mb-1">Disetujui / Selesai</p>
                  <p class="text-3xl font-bold text-emerald-600"><%= @disetujui %></p>
                </div>
              </div>
            </div>

            <div class="bg-white shadow rounded-lg px-4 py-5 sm:p-6 border border-slate-200">
              <h3 class="text-lg leading-6 font-medium text-slate-900 mb-4">Akses Cepat Tautan Manajerial</h3>
              <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                <a href="/admin/pengajuan" class="relative rounded-lg border border-slate-300 bg-white px-6 py-5 shadow-sm flex items-center space-x-3 hover:border-slate-400 hover:bg-slate-50 focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-indigo-500 transition-colors">
                  <div class="flex-shrink-0 bg-indigo-50 p-3 rounded-lg text-indigo-600">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
                  </div>
                  <div class="flex-1 min-w-0">
                    <span class="absolute inset-0" aria-hidden="true"></span>
                    <p class="text-sm font-medium text-slate-900">Validasi Pengajuan</p>
                    <p class="text-sm text-slate-500 truncate">Verifikasi akun dan KTM</p>
                  </div>
                </a>

                <a href="/admin/keluhan" class="relative rounded-lg border border-slate-300 bg-white px-6 py-5 shadow-sm flex items-center space-x-3 hover:border-slate-400 hover:bg-slate-50 focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-indigo-500 transition-colors">
                  <div class="flex-shrink-0 bg-indigo-50 p-3 rounded-lg text-indigo-600">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                  </div>
                  <div class="flex-1 min-w-0">
                    <span class="absolute inset-0" aria-hidden="true"></span>
                    <p class="text-sm font-medium text-slate-900">Keluhan Teknis</p>
                    <p class="text-sm text-slate-500 truncate">Tindak lanjut masalah portal</p>
                  </div>
                </a>

                <a href="/admin/users" class="relative rounded-lg border border-slate-300 bg-white px-6 py-5 shadow-sm flex items-center space-x-3 hover:border-slate-400 hover:bg-slate-50 focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-indigo-500 transition-colors">
                  <div class="flex-shrink-0 bg-indigo-50 p-3 rounded-lg text-indigo-600">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
                  </div>
                  <div class="flex-1 min-w-0">
                    <span class="absolute inset-0" aria-hidden="true"></span>
                    <p class="text-sm font-medium text-slate-900">Daftar Pengguna</p>
                    <p class="text-sm text-slate-500 truncate">Kelola peran & hak akses</p>
                  </div>
                </a>
              </div>
            </div>

          </div>
        </div>
      </main>
    </div>
    """
  end
end
