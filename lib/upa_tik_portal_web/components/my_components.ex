defmodule UpaTikPortalWeb.Components.MyComponents do
  use Phoenix.Component
  use Phoenix.VerifiedRoutes,
    endpoint: UpaTikPortalWeb.Endpoint,
    router: UpaTikPortalWeb.Router
  alias Phoenix.LiveView.JS

  slot :inner_block, required: true
  def navbar(assigns) do
    ~H"""
    <nav class="border-b border-slate-200 shadow-sm">
      <div class="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
        <a href="/portal/home" class="flex">
          <div class="flex items-center gap-2">
            <div class="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"/>
              </svg>
            </div>
            <span class="font-bold">UPA TIK Portal</span>
          </div>
        </a>
        <div class="flex items-center gap-4">
          <a href="/portal/home" class="text-sm hover:text-blue-600 transition-colors dark:text-white">Beranada</a>
          <a href="/portal/ajukan" class="text-sm hover:text-blue-600 transition-colors">Pengajuan</a>
          <a href="/portal/status" class="text-sm hover:text-blue-600 transition-colors">Status</a>
          <a href="/portal/keluhan" class="text-sm hover:text-blue-600 transition-colors">Lapor Masalah</a>
          <a href="/auth/logout" class="text-sm hover:text-red-600 transition-colors">Logout</a>
        </div>
      </div>
    </nav>
    <div class="max-w-7xl mx-auto mt-4 px-4">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :active_tab, :atom, default: :dashboard
  
  def navbarAdmin(assigns) do
    ~H"""
      <nav class="border-b border-slate-200 shadow-sm">
        <div class="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center shadow-md">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"/>
              </svg>
            </div>
            <div>
              <p class="font-bold text-sm leading-none">UPA TIK Admin</p>
              <p class="text-xs">Panel Manajemen</p>
            </div>
          </div>
          <div class="flex gap-6 items-center">
            <.nav_link navigate={~p"/admin"} active={@active_tab == :dashboard}>Dashboard</.nav_link>
            <.nav_link navigate={~p"/admin/pengajuan"} active={@active_tab == :pengajuan}>Pengajuan</.nav_link>
            <.nav_link navigate={~p"/admin/keluhan"} active={@active_tab == :keluhan}>Keluhan</.nav_link>
            <.nav_link navigate={~p"/admin/users"} active={@active_tab == :users}>Pengguna</.nav_link>
            <.nav_link navigate={~p"/admin/lowongan"} active={@active_tab == :lowongan}>Lowongan</.nav_link>
            <.nav_link navigate={~p"/auth/logout"} active={@active_tab == :logout}>Logout</.nav_link>
          </div>
        </div>
      </nav>
    """
  end

  attr :navigate, :string, required: true
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  def nav_link(assigns) do
    ~H"""
      <.link
        navigate={@navigate}
        class={[
          "text-sm font-medium transition-colors px-3 py-2 rounded-md",
          @active && "bg-blue-50 text-blue-700",
          !@active && "text-slate-600 hover:text-blue-600 hover:bg-slate-50"
        ]}
      >
        <%= render_slot(@inner_block) %>
      </.link>
    """
  end
end
