defmodule UpaTikPortalWeb.KeluhanLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Keluhans

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = UpaTikPortal.Accounts.get_user!(user_id)
    keluhans = Keluhans.list_keluhans_by_user(user_id)

    socket =
      socket
      |> assign(page_title: "Pengajuan Bermasalah – UPA TIK Portal")
      |> assign(current_user: user)
      |> assign(keluhans: keluhans)
      |> assign(subject: "")
      |> assign(description: "")
      |> assign(errors: %{})
      |> assign(submitted: false)

    {:ok, socket}
  end

  def handle_event("update_field", params, socket) do
    field_name = List.first(params["_target"])
    value = params[field_name]

    if field_name do
      {:noreply, assign(socket, String.to_existing_atom(field_name), value)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("submit", _params, socket) do
    user = socket.assigns.current_user

    attrs = %{
      "subject" => socket.assigns.subject,
      "description" => socket.assigns.description
    }

    case Keluhans.create_keluhan(user.id, attrs) do
      {:ok, _keluhan} ->
        keluhans = Keluhans.list_keluhans_by_user(user.id)

        {:noreply,
         socket
         |> assign(submitted: true, subject: "", description: "", errors: %{})
         |> assign(keluhans: keluhans)
         |> put_flash(:info, "Keluhan berhasil dikirim!")}

      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
        {:noreply, assign(socket, errors: errors)}
    end
  end

  def handle_event("new_keluhan", _params, socket) do
    {:noreply, assign(socket, submitted: false)}
  end

  def render(assigns) do
    ~H"""
    <nav class="sticky top-4 z-50 bg-white/80 backdrop-blur-md shadow-sm border border-slate-200/60 transition-all mb-8 rounded-2xl mx-auto max-w-5xl px-4 sm:px-6">
      <div class="flex justify-between h-16">
        <div class="flex items-center gap-3">
          <div class="p-1 bg-white rounded-xl shadow-sm border border-slate-100 flex items-center justify-center">
            <img src={~p"/images/utm_logo.png"} class="h-8 w-auto hover:scale-105 transition-transform drop-shadow-sm" alt="UTM Logo">
          </div>
          <span class="text-slate-900 font-extrabold text-lg tracking-tight">UPA TIK <span class="text-indigo-600">Portal</span></span>
        </div>
        <div class="flex items-center space-x-1 sm:space-x-4">
          <a href="/portal/ajukan" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Pengajuan</a>
          <a href="/portal/status" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Status</a>
          <a href="/portal/keluhan" class="px-4 py-2 rounded-xl text-indigo-600 bg-indigo-50 font-bold text-sm transition-all">Lapor</a>
          <div class="w-px h-6 bg-slate-200 mx-2 hidden sm:block"></div>
          <a href="/auth/logout" class="p-2 text-slate-400 hover:text-rose-500 transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
          </a>
        </div>
      </div>
    </nav>

    <div class="max-w-4xl mx-auto space-y-12 pb-20">
      <div class="text-center space-y-3">
        <h1 class="text-4xl font-extrabold text-slate-900 tracking-tight sm:text-5xl uppercase italic">
          Lapor <span class="text-rose-500">Kendala</span>
        </h1>
        <p class="text-slate-500 text-lg font-medium max-w-2xl mx-auto">Sampaikan masalah teknis Anda secara detail agar tim kami dapat membantu dengan cepat.</p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-12 gap-12 items-start">
        <div class="lg:col-span-12">
          <div class="bg-white p-10 rounded-[2.5rem] shadow-2xl shadow-slate-200/50 border border-slate-100 flex flex-col md:flex-row gap-12">
            <div class="md:w-1/3 space-y-8">
              <div class="space-y-4">
                <h2 class="text-2xl font-black text-slate-900 tracking-tight italic uppercase">Input <span class="text-rose-500">Laporan</span></h2>
                <p class="text-slate-400 text-sm font-medium">Lengkapi form di bawah untuk mengirimkan tiket laporan kendala baru ke tim UPA TIK.</p>
              </div>

              <%= if @submitted do %>
                <div class="bg-emerald-50 p-10 rounded-3xl border border-emerald-100 text-center animate-in zoom-in duration-500">
                  <div class="w-16 h-16 bg-emerald-500 text-white rounded-[2rem] flex items-center justify-center mx-auto mb-6 shadow-xl shadow-emerald-200">
                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/></svg>
                  </div>
                  <h3 class="text-xl font-black text-rose-900 mb-2">Terkirim!</h3>
                  <button phx-click="new_keluhan" class="text-rose-600 font-black text-xs uppercase tracking-widest hover:underline transition-all mt-4">Ketik Laporan Lain</button>
                </div>
              <% else %>
                <form phx-submit="submit" phx-change="update_field" class="space-y-6">
                  <div class="space-y-2">
                    <label class="block text-[10px] font-black text-slate-400 uppercase tracking-[.2em] ml-1">Subjek Masalah</label>
                    <input type="text" name="subject" value={@subject} placeholder="Contoh: Akun Terkunci" required
                      class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-4 focus:ring-rose-50 focus:border-rose-500 focus:bg-white outline-none transition-all font-bold text-slate-900 shadow-inner"/>
                  </div>
                  <div class="space-y-2">
                    <label class="block text-[10px] font-black text-slate-400 uppercase tracking-[.2em] ml-1">Detail Kronologi</label>
                    <textarea name="description" rows="5" placeholder="Jelaskan masalah secara detail..." required
                      class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-4 focus:ring-rose-50 focus:border-rose-500 focus:bg-white outline-none resize-none transition-all font-bold text-slate-900 shadow-inner"><%= @description %></textarea>
                  </div>
                  <button type="submit" class="w-full py-6 bg-rose-500 text-white font-black rounded-3xl shadow-xl shadow-rose-100 hover:bg-rose-600 hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center justify-center gap-3 group uppercase tracking-widest text-sm">
                    <span>Kirim Sekarang</span>
                    <svg class="w-6 h-6 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 7l5 5m0 0l-5 5m5-5H6"/></svg>
                  </button>
                </form>
              <% end %>
            </div>

            <div class="md:w-2/3 space-y-8">
              <div class="flex items-center justify-between border-b border-slate-50 pb-6">
                <h2 class="text-xl font-black text-slate-900 tracking-tight italic uppercase">Riwayat <span class="text-rose-500">Keluhan</span></h2>
                <div class="px-3 py-1 bg-slate-50 rounded-lg text-[10px] font-black text-slate-400 uppercase tracking-widest border border-slate-100">
                  Total: <%= Enum.count(@keluhans) %>
                </div>
              </div>

              <div class="space-y-6 overflow-y-auto max-h-[600px] pr-2 custom-scrollbar">
                <%= if Enum.empty?(@keluhans) do %>
                  <div class="p-20 text-center bg-slate-50 rounded-[2.5rem] border-4 border-dashed border-white shadow-inner">
                    <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-4 text-slate-200">
                      <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"/></svg>
                    </div>
                    <p class="text-slate-300 font-black uppercase tracking-[0.2em] text-[10px]">Data belum tersedia</p>
                  </div>
                <% else %>
                  <%= for keluhan <- @keluhans do %>
                    <% {badge_class, badge_text} = status_badge(keluhan.status) %>
                    <div class="group bg-white p-8 rounded-[2rem] border border-slate-100 shadow-sm hover:shadow-xl hover:shadow-slate-200 transition-all relative overflow-hidden">
                      <div class="flex flex-col sm:flex-row justify-between items-start gap-4 mb-6">
                        <span class={"text-[9px] font-black px-5 py-2 rounded-xl uppercase tracking-widest shadow-sm #{badge_class}"}>
                          <%= badge_text %>
                        </span>
                        <div class="text-right">
                          <p class="text-[9px] font-black text-slate-300 uppercase tracking-widest">Waktu Lapor</p>
                          <p class="text-xs font-bold text-slate-600"><%= Calendar.strftime(keluhan.inserted_at, "%d %b %Y") %></p>
                        </div>
                      </div>
                      <h4 class="font-black text-slate-900 text-xl tracking-tight group-hover:text-rose-500 transition-colors uppercase italic"><%= keluhan.subject %></h4>
                      <p class="text-slate-500 mt-3 font-medium leading-relaxed"><%= keluhan.description %></p>
                      
                      <%= if keluhan.admin_notes do %>
                        <div class="mt-8 p-6 bg-rose-50/50 rounded-3xl border border-rose-100 relative group/notes overflow-hidden">
                          <div class="absolute -left-1 top-6 w-1 h-10 bg-rose-500 rounded-full"></div>
                          <div class="absolute -right-6 -bottom-6 text-rose-100/50 rotate-12 group-hover/notes:scale-110 transition-transform">
                            <svg class="w-32 h-32" fill="currentColor" viewBox="0 0 20 20"><path d="M18 10c0 4.418-3.582 8-8 8s-8-3.582-8-8 3.582-8 8-8 8 3.582 8 8zm-8 3a1 1 0 001-1V9a1 1 0 00-2 0v3a1 1 0 001 1zm0-6a1 1 0 100-2 1 1 0 000 2z"/></svg>
                          </div>
                          <span class="text-[9px] font-black uppercase tracking-[.2em] text-rose-400 block mb-2">Tanggapan Petugas:</span>
                          <p class="text-slate-800 font-bold leading-relaxed relative z-10 italic">"<%= keluhan.admin_notes %>"</p>
                        </div>
                      <% end %>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp status_badge("baru"), do: {"bg-indigo-50 text-indigo-600 border border-indigo-100", "🆕 Baru"}
  defp status_badge("diproses"), do: {"bg-amber-50 text-amber-600 border border-amber-100", "⏳ Diproses"}
  defp status_badge("selesai"), do: {"bg-emerald-50 text-emerald-600 border border-emerald-100", "✅ Selesai"}
  defp status_badge(_), do: {"bg-slate-100 text-slate-700 border border-slate-100", "Unknown"}
end
