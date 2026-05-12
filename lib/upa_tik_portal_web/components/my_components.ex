defmodule UpaTikPortalWeb.Components.MyComponents do
  use Phoenix.Component
  use Phoenix.VerifiedRoutes,
    endpoint: UpaTikPortalWeb.Endpoint,
    router: UpaTikPortalWeb.Router
  alias Phoenix.LiveView.JS
  import UpaTikPortalWeb.CoreComponents

  attr :active_tab, :atom, default: :home
  slot :inner_block, required: true

  def navbar(assigns) do
    ~H"""
      <nav class="border-b border-slate-200 bg-transparent dark:bg-slate-900 shadow-sm sticky top-0 z-40">
        <div class="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">

          <!-- Left Section: Hamburger + Logo -->
          <div class="flex items-center gap-3">
            <!-- Hamburger Button (Mobile Only) -->
            <button
              type="button"
              class="p-2 -ml-2 md:hidden hover:bg-slate-100 rounded-lg"
              phx-click={show_mobile_sidebar()}
            >
              <.icon name="hero-bars-3" class="w-6 h-6" />
            </button>

            <.link navigate={~p"/portal/"} class="flex items-center gap-2 group">
              <div class="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center transition-transform group-hover:scale-110">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"/>
                </svg>
              </div>
              <span class="font-bold">UPA TIK Portal</span>
            </.link>
          </div>

          <!-- Right Section: Links + Profile -->
          <div class="flex items-center gap-6">
            <!-- Desktop Navigation (Hidden on Mobile) -->
            <div class="hidden md:flex items-center gap-2 border-r border-slate-200 pr-6">
              <.nav_link navigate={~p"/portal/"} active={@active_tab == :home}>Beranada</.nav_link>
              <.nav_link navigate={~p"/portal/lowongan"} active={@active_tab == :lowongan}>Lowongan</.nav_link>
              <.nav_link navigate={~p"/portal/ajukan"} active={@active_tab == :ajukan}>Pengajuan</.nav_link>
              <.nav_link navigate={~p"/portal/status"} active={@active_tab == :status}>Status</.nav_link>
              <.nav_link navigate={~p"/portal/keluhan"} active={@active_tab == :keluhan}>Lapor Masalah</.nav_link>
            </div>

            <!-- Profile Dropdown (Tetap muncul di mobile/desktop) -->
            <div class="relative">
              <button
                type="button"
                class="group cursor-pointer flex items-center gap-2 p-1 rounded-full hover:bg-slate-100 transition-colors"
                id="user-menu-button"
                phx-click={JS.toggle(to: "#profile-dropdown", in: {"ease-out duration-100", "opacity-0 scale-95", "opacity-100 scale-100"}, out: {"ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"})}
                phx-click-away={JS.hide(to: "#profile-dropdown")}
              >
                <div class="w-8 h-8 rounded-full bg-gradient-to-tr from-blue-500 to-indigo-600 flex items-center justify-center text-white text-xs font-bold shadow-sm transition-transform group-hover:scale-105">
                  M
                </div>

                <!-- Gunakan group-hover: untuk memicu perubahan saat button di-hover -->
                <span class="hidden sm:block text-sm font-medium transition-colors group-hover:text-blue-600">
                  Maulana
                </span>

                <.icon
                  name="hero-chevron-down"
                  class="w-4 h-4 transition-colors group-hover:text-blue-600"
                />
              </button>

              <!-- Dropdown Menu Code (Sama seperti sebelumnya) -->
              <div id="profile-dropdown" class="hidden absolute right-0 mt-2 w-48 bg-white rounded-xl shadow-lg z-50 overflow-hidden">
                <!-- ... isi dropdown ... -->
                <div class="px-4 py-3 border-b border-slate-100 bg-slate-50/50">
                  <p class="text-xs text-slate-500">Masuk sebagai</p>
                  <p class="text-sm font-semibold text-slate-900 truncate">Maulana</p>
                </div>

                <div class="py-1">
                  <.link navigate={~p"/portal/profile"} class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 transition-colors">
                    <.icon name="hero-user" class="w-4 h-4" /> Profil Saya
                  </.link>
                  <.link navigate={~p"/portal/setting"} class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 transition-colors">
                    <.icon name="hero-cog-6-tooth" class="w-4 h-4" /> Pengaturan
                  </.link>
                  <.link navigate={~p"/portal/keluhan"} class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 transition-colors">
                    <.icon name="hero-chat-bubble-left-right" class="w-4 h-4" /> Lapor Masalah
                  </.link>
                </div>

                <div class="py-1 border-t border-slate-100 bg-red-50/20">
                  <.link href={~p"/auth/logout"} class="flex items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors font-medium">
                    <.icon name="hero-arrow-right-on-rectangle" class="w-4 h-4" /> Keluar
                  </.link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </nav>

      <!-- Mobile Sidebar (Drawer) -->
      <.mobile_sidebar active_tab={@active_tab} />

      <main class="max-w-7xl mx-auto mt-4 px-4 pb-20">
        <%= render_slot(@inner_block) %>
      </main>
    """
  end

  attr :active_tab, :atom, default: :home
  defp mobile_sidebar(assigns) do
    ~H"""
      <div id="mobile-sidebar-container" class="relative z-50 md:hidden hidden" role="dialog" aria-modal="true">
        <!-- Backdrop -->
        <div
          id="mobile-sidebar-backdrop"
          class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm"
          phx-click={hide_mobile_sidebar()}
        ></div>

        <!-- Sidebar Panel -->
        <div
          id="mobile-sidebar-panel"
          class="fixed inset-y-0 left-0 w-full max-w-xs bg-white shadow-xl flex flex-col overflow-y-auto"
        >
          <div class="p-6 border-b border-slate-100 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <div class="w-7 h-7 rounded-lg bg-blue-600 flex items-center justify-center">
                <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"/></svg>
              </div>
              <span class="font-bold text-slate-900">Menu Portal</span>
            </div>
            <button type="button" phx-click={hide_mobile_sidebar()} class="p-2 text-slate-400 hover:text-slate-500">
              <.icon name="hero-x-mark" class="w-6 h-6" />
            </button>
          </div>

          <nav class="flex-1 px-4 py-6 space-y-2">
            <.mobile_nav_link navigate={~p"/portal/"} active={@active_tab == :home} icon="hero-home">Beranda</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/portal/lowongan"} active={@active_tab == :lowongan} icon="hero-briefcase">Lowongan</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/portal/ajukan"} active={@active_tab == :ajukan} icon="hero-document-plus">Pengajuan</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/portal/status"} active={@active_tab == :status} icon="hero-clock">Status</.mobile_nav_link>
            <hr class="border-slate-100 my-4" />
            <.mobile_nav_link navigate={~p"/portal/keluhan"} active={@active_tab == :keluhan} icon="hero-chat-bubble-left-right">Lapor Masalah</.mobile_nav_link>
          </nav>

          <div class="p-4 border-t border-slate-100">
            <.link href={~p"/auth/logout"} method="delete" class="flex items-center gap-3 w-full px-4 py-3 text-sm font-medium text-red-600 hover:bg-red-50 rounded-xl transition-colors">
              <.icon name="hero-arrow-right-on-rectangle" class="w-5 h-5" /> Keluar
            </.link>
          </div>
        </div>
      </div>
    """
  end

  attr :navigate, :any, required: true
  attr :active, :boolean, default: false
  attr :icon, :string
  slot :inner_block, required: true

  defp mobile_nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl transition-all",
        @active && "bg-blue-600 text-white shadow-md shadow-blue-200",
        !@active && "text-slate-600 hover:bg-slate-50"
      ]}
    >
      <.icon name={@icon} class={["w-5 h-5", @active && "text-white", !@active && "text-slate-400"]} />
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  attr :active_tab, :atom, default: :dashboard

  def navbarAdmin(assigns) do
    ~H"""
      <nav class="border-b border-slate-200 shadow-sm bg-transparent dark:bg-slate-900">
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

  defp nav_link(assigns) do
    ~H"""
      <.link
        navigate={@navigate}
        class={[
          "text-sm font-medium transition-colors px-3 py-2 rounded-md",
          @active && "bg-blue-50 text-blue-700",
          !@active && "hover:text-blue-600 hover:bg-slate-50"
        ]}
      >
        <%= render_slot(@inner_block) %>
      </.link>
    """
  end

  defp show_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.show(to: "#mobile-sidebar-container")
    |> JS.transition("fade-in", to: "#mobile-sidebar-backdrop")
    |> JS.transition({"ease-out duration-300", "-translate-x-full", "translate-x-0"}, to: "#mobile-sidebar-panel")
    |> JS.add_class("overflow-hidden", to: "body")
  end

  defp hide_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.transition("fade-out", to: "#mobile-sidebar-backdrop")
    |> JS.transition({"ease-in duration-200", "translate-x-0", "-translate-x-full"}, to: "#mobile-sidebar-panel")
    |> JS.hide(to: "#mobile-sidebar-container", transition: "fade-out")
    |> JS.remove_class("overflow-hidden", to: "body")
  end
end
