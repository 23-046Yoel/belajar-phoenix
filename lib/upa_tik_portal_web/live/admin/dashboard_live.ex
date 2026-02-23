defmodule UpaTikPortalWeb.Admin.DashboardLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  def mount(_params, _session, socket) do
    stats = Requests.stats()

    {:ok,
     assign(socket,
       page_title: "Dashboard Admin – UPA TIK Portal",
       pending: Map.get(stats, "pending", 0),
       disetujui: Map.get(stats, "disetujui", 0),
       ditolak: Map.get(stats, "ditolak", 0),
       total: Enum.sum(Map.values(stats))
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50">
      <%!-- Admin Navbar --%>
      <nav class="bg-white border-b border-slate-200 shadow-sm">
        <div class="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center shadow-md">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"/>
              </svg>
            </div>
            <div>
              <p class="font-bold text-slate-900 text-sm leading-none">UPA TIK Admin</p>
              <p class="text-xs text-slate-500">Panel Manajemen</p>
            </div>
          </div>
          <div class="flex gap-4 items-center">
            <a href="/admin/pengajuan" class="text-sm font-medium text-blue-600 hover:text-blue-800 transition-colors">Pengajuan</a>
            <a href="/auth/logout" class="text-sm text-slate-500 hover:text-red-600 transition-colors">Logout</a>
          </div>
        </div>
      </nav>

      <div class="max-w-7xl mx-auto px-6 py-8">
        <div class="mb-8">
          <h1 class="text-2xl font-bold text-slate-900">Dashboard</h1>
          <p class="text-slate-500 mt-1">Ringkasan pengajuan aktivasi &amp; reset email kampus</p>
        </div>

        <!-- Stats Cards -->
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <div class="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm">
            <p class="text-xs font-semibold uppercase tracking-wide text-slate-500">Total</p>
            <p class="text-4xl font-bold text-slate-900 mt-1"><%= @total %></p>
            <p class="text-xs text-slate-400 mt-1">Semua pengajuan</p>
          </div>
          <div class="bg-amber-50 rounded-2xl border border-amber-200 p-5 shadow-sm">
            <p class="text-xs font-semibold uppercase tracking-wide text-amber-700">Menunggu</p>
            <p class="text-4xl font-bold text-amber-600 mt-1"><%= @pending %></p>
            <p class="text-xs text-amber-500 mt-1">Perlu ditindaklanjuti</p>
          </div>
          <div class="bg-green-50 rounded-2xl border border-green-200 p-5 shadow-sm">
            <p class="text-xs font-semibold uppercase tracking-wide text-green-700">Disetujui</p>
            <p class="text-4xl font-bold text-green-600 mt-1"><%= @disetujui %></p>
            <p class="text-xs text-green-500 mt-1">Telah diproses</p>
          </div>
          <div class="bg-red-50 rounded-2xl border border-red-200 p-5 shadow-sm">
            <p class="text-xs font-semibold uppercase tracking-wide text-red-700">Ditolak</p>
            <p class="text-4xl font-bold text-red-600 mt-1"><%= @ditolak %></p>
            <p class="text-xs text-red-500 mt-1">Tidak memenuhi syarat</p>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
          <h2 class="font-semibold text-slate-800 mb-4">Aksi Cepat</h2>
          <div class="flex gap-3 flex-wrap">
            <a href="/admin/pengajuan"
              class="flex items-center gap-2 px-5 py-2.5 bg-blue-600 text-white rounded-xl font-medium text-sm hover:bg-blue-700 transition-colors shadow-md">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
              </svg>
              Lihat Semua Pengajuan
            </a>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
