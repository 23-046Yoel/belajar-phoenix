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
    <div class="min-h-screen bg-slate-50">
      <%!-- Admin Navbar --%>
      <.navbarAdmin active_tab={:dashboard} />

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
          <div class="bg-orange-50 rounded-2xl border border-orange-200 p-5 shadow-sm">
            <p class="text-xs font-semibold uppercase tracking-wide text-orange-600">Keluhan Baru</p>
            <p class="text-4xl font-bold text-orange-600 mt-1"><%= @keluhan_baru %></p>
            <p class="text-xs text-orange-400 mt-1">Perlu ditindaklanjuti</p>
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
            <a href="/admin/keluhan"
              class="flex items-center gap-2 px-5 py-2.5 bg-orange-500 text-white rounded-xl font-medium text-sm hover:bg-orange-600 transition-colors shadow-md">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
              </svg>
              Keluhan Masuk (<%= @keluhan_baru %> Baru)
            </a>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
