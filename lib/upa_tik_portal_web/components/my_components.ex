defmodule UpaTikPortalWeb.Components.MyComponents do
  use Phoenix.Component

  slot :inner_block, required: true

  def navbar(assigns) do
    ~H"""
    <nav class="bg-white border-b border-slate-200 shadow-sm">
      <div class="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
        <div class="flex items-center gap-2">
          <div class="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center">
            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"/>
            </svg>
          </div>
          <span class="font-bold text-slate-800">UPA TIK Portal</span>
        </div>
        <div class="flex items-center gap-4">
          <a href="/portal/ajukan" class="text-sm text-slate-500 hover:text-blue-600 transition-colors">Pengajuan</a>
          <a href="/portal/status" class="text-sm text-slate-500 hover:text-blue-600 transition-colors">Status</a>
          <a href="/portal/keluhan" class="text-sm text-blue-600 font-semibold">Lapor Masalah</a>
          <a href="/auth/logout" class="text-sm text-slate-500 hover:text-red-600 transition-colors">Logout</a>
        </div>
      </div>
    </nav>
    <div class="max-w-7xl mx-auto mt-4 px-4">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
