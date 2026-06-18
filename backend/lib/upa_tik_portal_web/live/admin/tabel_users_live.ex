defmodule UpaTikPortalWeb.Admin.TabelUsersLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Accounts

  @impl true
  def mount(_params, _session, socket) do
    # ✅ Ambil semua data user dari database
    users = Accounts.list_users()

    {:ok,
     assign(socket,
       users: users,
       page_title: "Tabel Data Pengguna – Admin UPA TIK",
       search: ""
     )}
  end

  @impl true
  def handle_event("search", %{"search" => q}, socket) do
    q = String.downcase(q)

    filtered =
      Accounts.list_users()
      |> Enum.filter(fn u ->
        String.contains?(String.downcase(u.name), q) or
          String.contains?(String.downcase(u.email), q)
      end)

    {:noreply, assign(socket, users: filtered, search: q)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Navbar Admin --%>
    <nav class="bg-indigo-700 shadow-lg border-b border-indigo-800">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center gap-3">
            <div class="bg-white p-1 rounded">
              <img src={~p"/images/utm_logo.png"} class="h-6 w-auto" alt="UTM Logo" />
            </div>
            <span class="text-white font-bold text-lg tracking-tight">UPA TIK Admin</span>
          </div>

          <div class="hidden md:flex items-baseline space-x-2">
            <a href="/admin" class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium">
              Dashboard
            </a>
            <a href="/admin/pengajuan" class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium">
              Pengajuan
            </a>
            <a href="/admin/keluhan" class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium">
              Keluhan
            </a>
            <a href="/admin/users" class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium">
              Pengguna
            </a>
            <a href="/admin/tabel-users" class="bg-indigo-900 text-white px-3 py-2 rounded-md text-sm font-medium">
              Tabel Users
            </a>
            <a href="/auth/logout" class="text-indigo-100 hover:bg-rose-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium">
              Keluar
            </a>
          </div>
        </div>
      </div>
    </nav>

    <%!-- Konten Utama --%>
    <div class="min-h-screen bg-slate-50 py-10 px-4">
      <div class="max-w-6xl mx-auto space-y-6">

        <%!-- Header Halaman --%>
        <div class="bg-white rounded-2xl shadow border border-slate-100 p-8 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div>
            <h1 class="text-3xl font-black text-slate-900 tracking-tight uppercase italic">
              Tabel <span class="text-indigo-600">Data Pengguna</span>
            </h1>
            <p class="text-slate-400 text-xs font-bold uppercase tracking-widest mt-1">
              Seluruh pengguna terdaftar di sistem
            </p>
          </div>
          <div class="px-8 py-3 bg-indigo-600 text-white rounded-2xl shadow-lg flex flex-col items-center">
            <span class="text-[9px] font-black uppercase tracking-widest text-indigo-100/70 mb-0.5">
              Total Pengguna
            </span>
            <span class="text-2xl font-black">{length(@users)}</span>
          </div>
        </div>

        <%!-- Kotak Pencarian --%>
        <div class="bg-white rounded-2xl shadow border border-slate-100 p-6">
          <form phx-change="search" id="form-search-users">
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <.icon name="hero-magnifying-glass" class="w-5 h-5 text-slate-400" />
              </div>
              <input
                type="text"
                name="search"
                value={@search}
                placeholder="Cari berdasarkan nama atau email..."
                class="w-full pl-12 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium text-slate-700 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-indigo-400 transition-all"
              />
            </div>
          </form>
        </div>

        <%!-- Tabel Data dari Database --%>
        <div class="bg-white rounded-2xl shadow border border-slate-100 overflow-hidden">
          <div class="overflow-x-auto">
            <table id="tabel-users" class="w-full text-left border-collapse">

              <%!-- Header kolom tabel --%>
              <thead class="bg-slate-50 border-b border-slate-200">
                <tr>
                  <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">
                    No
                  </th>
                  <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">
                    Nama Pengguna
                  </th>
                  <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">
                    Email
                  </th>
                  <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] text-center">
                    Role / Hak Akses
                  </th>
                  <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">
                    Google UID
                  </th>
                  <th class="px-6 py-5 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] text-right">
                    Tanggal Daftar
                  </th>
                </tr>
              </thead>

              <%!-- Isi tabel - loop dari database --%>
              <tbody class="divide-y divide-slate-100">
                <%= if @users == [] do %>
                  <tr>
                    <td colspan="6" class="px-6 py-16 text-center text-slate-400 font-bold uppercase tracking-widest text-sm">
                      Tidak ada data pengguna ditemukan
                    </td>
                  </tr>
                <% end %>

                <%= for {user, index} <- Enum.with_index(@users, 1) do %>
                  <tr class="hover:bg-indigo-50/30 transition-colors cursor-default">

                    <%!-- Nomor urut --%>
                    <td class="px-6 py-5">
                      <span class="text-xs font-black text-slate-300 font-mono">{index}</span>
                    </td>

                    <%!-- Nama + inisial avatar --%>
                    <td class="px-6 py-5">
                      <div class="flex items-center gap-3">
                        <div class="w-10 h-10 bg-indigo-600 text-white rounded-xl flex items-center justify-center font-black text-base shadow">
                          {String.at(user.name, 0) |> String.upcase()}
                        </div>
                        <div>
                          <p class="font-bold text-slate-800 text-sm">{user.name}</p>
                          <p class="text-[10px] text-slate-400 font-mono">ID: {user.id}</p>
                        </div>
                      </div>
                    </td>

                    <%!-- Email --%>
                    <td class="px-6 py-5">
                      <span class="text-xs font-bold text-slate-600 font-mono bg-slate-50 px-3 py-1.5 rounded-lg border border-slate-100">
                        {user.email}
                      </span>
                    </td>

                    <%!-- Role / badge warna --%>
                    <td class="px-6 py-5 text-center">
                      <span class={[
                        "px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest",
                        user.role == "admin" && "bg-slate-900 text-white",
                        user.role != "admin" && "bg-indigo-100 text-indigo-700 border border-indigo-200"
                      ]}>
                        {user.role}
                      </span>
                    </td>

                    <%!-- Google UID --%>
                    <td class="px-6 py-5">
                      <span class="text-[11px] font-mono text-slate-400">
                        {if user.google_uid, do: String.slice(user.google_uid, 0..14) <> "...", else: "—"}
                      </span>
                    </td>

                    <%!-- Tanggal daftar --%>
                    <td class="px-6 py-5 text-right">
                      <p class="text-xs font-bold text-slate-500">
                        {Calendar.strftime(user.inserted_at, "%d %b %Y")}
                      </p>
                      <p class="text-[10px] text-slate-300 font-mono">
                        {Calendar.strftime(user.inserted_at, "%H:%M")} WIB
                      </p>
                    </td>

                  </tr>
                <% end %>
              </tbody>

            </table>
          </div>
        </div>

      </div>
    </div>
    """
  end
end
