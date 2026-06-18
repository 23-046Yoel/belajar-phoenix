defmodule UpaTikPortalWeb.Admin.DashboardLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  @impl true
  def mount(_params, _session, socket) do
    categories = [
      {"sso_gmail", "SSO & Akun Gmail"},
      {"internet_wifi", "Koneksi Wi-Fi & Internet"},
      {"portal_sia", "Portal SIA / Akademik"},
      {"hardware_fasilitas", "Fasilitas Lab / Hardware"},
      {"lainnya", "Lainnya / Umum"}
    ]

    socket =
      assign(socket,
        page_title: "Dashboard Admin – UPA TIK Portal",
        start_date: "",
        end_date: "",
        selected_category: nil,
        categories: categories,
        selected_month: nil
      )
      |> assign_stats("", "")

    {:ok, socket}
  end

  defp assign_stats(socket, start_date, end_date) do
    filters = %{start_date: start_date, end_date: end_date}
    stats = Requests.stats_filtered(filters)
    keluhan_stats = UpaTikPortal.Keluhans.stats_filtered(filters)
    monthly_stats = Requests.get_monthly_stats_filtered(filters)
    category_stats = UpaTikPortal.Keluhans.get_category_stats_filtered(filters)

    # Donut calculations
    p = Map.get(stats, "pending", 0)
    a = Map.get(stats, "disetujui", 0)
    r = Map.get(stats, "ditolak", 0)
    tot = p + a + r

    circ = 377.0

    {disetujui_len, pending_len, ditolak_len, pending_offset, ditolak_offset, disetujui_pct,
     pending_pct,
     ditolak_pct} =
      if tot > 0 do
        d_len = a / tot * circ
        p_len = p / tot * circ
        r_len = r / tot * circ
        p_off = -d_len
        r_off = -(d_len + p_len)

        d_pct = Float.round(a / tot * 100, 1)
        p_pct = Float.round(p / tot * 100, 1)
        r_pct = Float.round(r / tot * 100, 1)

        {d_len, p_len, r_len, p_off, r_off, d_pct, p_pct, r_pct}
      else
        {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}
      end

    max_monthly =
      Enum.map(monthly_stats, fn m -> m.aktivasi + m.reset end)
      |> (fn l -> if Enum.empty?(l), do: [1], else: l end).()
      |> Enum.max()
      |> Kernel.max(1)

    max_category =
      if Enum.empty?(Map.values(category_stats)) do
        1
      else
        Enum.max(Map.values(category_stats)) |> Kernel.max(1)
      end

    selected_category = socket.assigns[:selected_category]

    category_keluhans =
      if selected_category do
        UpaTikPortal.Keluhans.list_keluhans_filtered(%{
          category: selected_category,
          start_date: start_date,
          end_date: end_date
        })
      else
        []
      end

    assign(socket,
      pending: p,
      disetujui: a,
      ditolak: r,
      total: tot,
      keluhan_baru: Map.get(keluhan_stats, "baru", 0),
      monthly_stats: monthly_stats,
      category_stats: category_stats,
      max_monthly: max_monthly,
      max_category: max_category,
      tot: tot,
      circ: circ,
      disetujui_len: disetujui_len,
      pending_len: pending_len,
      ditolak_len: ditolak_len,
      pending_offset: pending_offset,
      ditolak_offset: ditolak_offset,
      disetujui_pct: disetujui_pct,
      pending_pct: pending_pct,
      ditolak_pct: ditolak_pct,
      selected_month:
        case monthly_stats do
          [] ->
            nil

          list ->
            curr = socket.assigns[:selected_month]
            if Enum.any?(list, &(&1.month == curr)), do: curr, else: List.last(list).month
        end,
      category_keluhans: category_keluhans
    )
  end

  defp format_month(month_str) do
    case String.split(month_str, "-") do
      [year, month] ->
        name =
          case month do
            "01" -> "Jan"
            "02" -> "Feb"
            "03" -> "Mar"
            "04" -> "Apr"
            "05" -> "Mei"
            "06" -> "Jun"
            "07" -> "Jul"
            "08" -> "Agu"
            "09" -> "Sep"
            "10" -> "Okt"
            "11" -> "Nov"
            "12" -> "Des"
            _ -> month
          end

        "#{name} #{String.slice(year, 2..3)}"

      _ ->
        month_str
    end
  end

  defp format_status("baru"), do: "Baru"
  defp format_status("diproses"), do: "Diproses"
  defp format_status("selesai"), do: "Selesai"
  defp format_status(s), do: s

  @impl true
  def handle_event("select_month", %{"month" => month}, socket) do
    selected = if socket.assigns.selected_month == month, do: nil, else: month
    {:noreply, assign(socket, selected_month: selected)}
  end

  @impl true
  def handle_event("filter_dates", %{"start_date" => start_date, "end_date" => end_date}, socket) do
    {:noreply,
     socket
     |> assign(start_date: start_date, end_date: end_date)
     |> assign_stats(start_date, end_date)}
  end

  @impl true
  def handle_event("reset_dates", _params, socket) do
    {:noreply,
     socket
     |> assign(start_date: "", end_date: "")
     |> assign_stats("", "")}
  end

  @impl true
  def handle_event("select_category", %{"category" => category}, socket) do
    selected = if socket.assigns.selected_category == category, do: nil, else: category
    socket = assign(socket, selected_category: selected)
    {:noreply, assign_stats(socket, socket.assigns.start_date, socket.assigns.end_date)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50 shadow-inner">
      <nav class="bg-indigo-700 shadow-lg border-b border-indigo-800">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between h-16">
            <div class="flex items-center">
              <div class="flex-shrink-0 flex items-center gap-3">
                <div class="bg-white p-1 rounded">
                  <img src={~p"/images/utm_logo.png"} class="h-6 w-auto" alt="UTM Logo" />
                </div>
                <span class="text-white font-bold text-lg tracking-tight">UPA TIK Admin</span>
              </div>

              <div class="hidden md:block">
                <div class="ml-10 flex items-baseline space-x-4">
                  <a
                    href="/admin"
                    class="bg-indigo-900 text-white px-3 py-2 rounded-md text-sm font-medium"
                  >
                    Dashboard
                  </a>
                  <a
                    href="/admin/pengajuan"
                    class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium"
                  >
                    Pengajuan
                  </a>
                  <a
                    href="/admin/keluhan"
                    class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium"
                  >
                    Keluhan
                  </a>
                  <a
                    href="/admin/users"
                    class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium"
                  >
                    Pengguna
                  </a>
                  <a
                    href="/admin/logs"
                    class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium"
                  >
                    Log Audit
                  </a>
                </div>
              </div>
            </div>

            <div class="hidden md:block">
              <div class="ml-4 flex items-center md:ml-6">
                <a
                  href="/auth/logout"
                  class="text-indigo-100 hover:bg-indigo-600 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors flex gap-2 items-center"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
                    />
                  </svg>
                  Keluar
                </a>
              </div>
            </div>
          </div>
        </div>
      </nav>

      <header class="bg-white shadow-sm border-b border-slate-200">
        <div class="max-w-7xl mx-auto py-4 px-4 sm:px-6 lg:px-8 flex justify-between items-center">
          <h1 class="text-2xl font-bold text-slate-800">Dashboard</h1>

          <p class="text-sm text-slate-500">{Calendar.strftime(DateTime.utc_now(), "%d %B %Y")}</p>
        </div>
      </header>

      <main>
        <div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
          <div class="px-4 py-6 sm:px-0">
            <!-- Filter Tanggal & Ekspor Laporan -->
            <div class="bg-white rounded-[1.5rem] border border-slate-100 p-6 shadow-md mb-8 flex flex-col lg:flex-row items-center justify-between gap-6">
              <div class="space-y-1 text-center lg:text-left">
                <h2 class="text-sm font-black text-slate-900 uppercase tracking-wider">
                  Filter Periode & Ekspor Laporan
                </h2>
                <p class="text-xs text-slate-400 font-bold uppercase tracking-wider">
                  Saring statistik & Unduh Laporan Excel / CSV
                </p>
              </div>

              <form
                phx-change="filter_dates"
                class="flex flex-col sm:flex-row items-center gap-4 w-full lg:w-auto"
              >
                <div class="flex flex-col gap-1 w-full sm:w-auto">
                  <label class="text-[9px] font-black uppercase tracking-wider text-slate-400">
                    Mulai
                  </label>
                  <input
                    type="date"
                    name="start_date"
                    value={@start_date}
                    class="px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold focus:ring-4 focus:ring-indigo-50 focus:border-indigo-500 outline-none transition-all"
                  />
                </div>
                <div class="flex flex-col gap-1 w-full sm:w-auto">
                  <label class="text-[9px] font-black uppercase tracking-wider text-slate-400">
                    Sampai
                  </label>
                  <input
                    type="date"
                    name="end_date"
                    value={@end_date}
                    class="px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold focus:ring-4 focus:ring-indigo-50 focus:border-indigo-500 outline-none transition-all"
                  />
                </div>
                <div class="flex items-end gap-2 self-end w-full sm:w-auto pt-4 sm:pt-0">
                  <button
                    type="button"
                    phx-click="reset_dates"
                    class="px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-black uppercase tracking-widest transition-all"
                  >
                    Reset
                  </button>
                  <a
                    href={~p"/admin/reports/all?start_date=#{@start_date}&end_date=#{@end_date}"}
                    class="px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-black uppercase tracking-widest transition-all flex items-center gap-1.5 shadow-md shadow-indigo-100"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                      />
                    </svg>
                    Ekspor Laporan Konsolidasi
                  </a>
                </div>
              </form>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
              <div class="bg-white rounded-lg shadow p-6 border border-slate-100 flex items-center">
                <div class="p-3 rounded-full bg-slate-100 text-slate-600 mr-4">
                  <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M7 3a1 1 0 000 2h6a1 1 0 100-2H7zM4 7a1 1 0 011-1h10a1 1 0 110 2H5a1 1 0 01-1-1zM2 11a2 2 0 012-2h12a2 2 0 012 2v4a2 2 0 01-2 2H4a2 2 0 01-2-2v-4z" />
                  </svg>
                </div>

                <div>
                  <p class="text-sm font-medium text-slate-500 mb-1">Total Laporan</p>

                  <p class="text-3xl font-bold text-slate-900">{@total}</p>
                </div>
              </div>

              <div class="bg-white rounded-lg shadow p-6 border border-slate-100 flex items-center">
                <div class="p-3 rounded-full bg-amber-50 text-amber-600 mr-4">
                  <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fill-rule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </div>

                <div>
                  <p class="text-sm font-medium text-slate-500 mb-1">Pengajuan Menunggu</p>

                  <p class="text-3xl font-bold text-amber-600">{@pending}</p>
                </div>
              </div>

              <div class="bg-white rounded-lg shadow p-6 border border-slate-100 flex items-center">
                <div class="p-3 rounded-full bg-rose-50 text-rose-600 mr-4">
                  <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fill-rule="evenodd"
                      d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </div>

                <div>
                  <p class="text-sm font-medium text-slate-500 mb-1">Keluhan Baru</p>

                  <p class="text-3xl font-bold text-rose-600">{@keluhan_baru}</p>
                </div>
              </div>

              <div class="bg-white rounded-lg shadow p-6 border border-slate-100 flex items-center">
                <div class="p-3 rounded-full bg-emerald-50 text-emerald-600 mr-4">
                  <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fill-rule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </div>

                <div>
                  <p class="text-sm font-medium text-slate-500 mb-1">Disetujui / Selesai</p>

                  <p class="text-3xl font-bold text-emerald-600">{@disetujui}</p>
                </div>
              </div>
            </div>
            
    <!-- SECTION ANALYTICS GRAPHICS -->
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 mb-8">
              <!-- Tren Pengajuan (Stacked Bar) -->
              <div class="lg:col-span-8 bg-white rounded-2xl shadow-lg border border-slate-100 p-8">
                <div class="flex justify-between items-center mb-6">
                  <div>
                    <h3 class="text-lg font-black text-slate-900 uppercase italic tracking-tight">
                      Tren <span class="text-indigo-600">Pengajuan Akun</span>
                    </h3>
                    <p class="text-xs text-slate-400 font-bold uppercase tracking-widest mt-0.5">
                      6 Bulan Terakhir
                    </p>
                  </div>
                  <div class="flex items-center gap-4 text-xs font-bold text-slate-500">
                    <div class="flex items-center gap-1.5">
                      <span class="w-3 h-3 bg-indigo-600 rounded-sm"></span>
                      <span>Aktivasi</span>
                    </div>
                    <div class="flex items-center gap-1.5">
                      <span class="w-3 h-3 bg-purple-500 rounded-sm"></span>
                      <span>Reset</span>
                    </div>
                  </div>
                </div>

                <%= if @selected_month do %>
                  <% selected_data = Enum.find(@monthly_stats, &(&1.month == @selected_month)) %>
                  <%= if selected_data do %>
                    <% total_pengajuan = selected_data.aktivasi + selected_data.reset %>
                    <div class="mb-4 bg-indigo-50 border border-indigo-100 rounded-xl p-4 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 transition-all duration-300">
                      <div>
                        <span class="text-[10px] font-black text-indigo-400 uppercase tracking-widest font-mono">
                          Bulan Terpilih
                        </span>
                        <h4 class="text-base font-black text-indigo-900 uppercase font-mono">
                          {format_month(@selected_month)}
                        </h4>
                      </div>
                      <div class="flex gap-3">
                        <div class="bg-white px-3 py-1.5 rounded-lg border border-indigo-100 shadow-sm flex flex-col">
                          <span class="text-[9px] text-slate-400 font-black uppercase tracking-wider">
                            Total
                          </span>
                          <span class="text-sm font-black text-slate-900 font-mono text-center">
                            {total_pengajuan}
                          </span>
                        </div>
                        <div class="bg-white px-3 py-1.5 rounded-lg border border-indigo-100 shadow-sm flex flex-col">
                          <span class="text-[9px] text-indigo-500 font-black uppercase tracking-wider">
                            Aktivasi
                          </span>
                          <span class="text-sm font-black text-indigo-600 font-mono text-center">
                            {selected_data.aktivasi}
                          </span>
                        </div>
                        <div class="bg-white px-3 py-1.5 rounded-lg border border-indigo-100 shadow-sm flex flex-col">
                          <span class="text-[9px] text-purple-500 font-black uppercase tracking-wider">
                            Reset
                          </span>
                          <span class="text-sm font-black text-purple-600 font-mono text-center">
                            {selected_data.reset}
                          </span>
                        </div>
                      </div>
                    </div>
                  <% end %>
                <% else %>
                  <div class="mb-4 text-xs font-semibold text-slate-400 italic bg-slate-50 border border-slate-100 rounded-xl p-3 text-center">
                    💡 Tips: Klik salah satu diagram batang di bawah untuk melihat detail jumlah pengajuan bulan tersebut.
                  </div>
                <% end %>

                <div class="relative w-full h-64 flex items-end">
                  <svg viewBox="0 0 500 220" class="w-full h-full" preserveAspectRatio="none">
                    <!-- Y Axis grid lines -->
                    <%= for i <- 0..4 do %>
                      <% y_val = 30 + i * 35 %>
                      <% label_val = round(@max_monthly - i * @max_monthly / 4) %>
                      <line
                        x1="30"
                        y1={y_val}
                        x2="480"
                        y2={y_val}
                        stroke="#e2e8f0"
                        stroke-dasharray="4"
                        stroke-width="1"
                      />
                      <text
                        x="25"
                        y={y_val + 4}
                        text-anchor="end"
                        class="text-[9px] fill-slate-400 font-mono"
                      >
                        {label_val}
                      </text>
                    <% end %>
                    
    <!-- Bars -->
                    <%= for {month_data, idx} <- Enum.with_index(@monthly_stats) do %>
                      <% # Bar configuration
                      col_width = (500 - 2 * 30) / 6
                      x = 30 + idx * col_width + col_width / 2
                      scale = 140.0 / @max_monthly
                      akt_h = month_data.aktivasi * scale
                      rst_h = month_data.reset * scale
                      bar_w = 24
                      is_selected = @selected_month == month_data.month %>
                      <!-- Interactive Column Group -->
                      <g
                        phx-click="select_month"
                        phx-value-month={month_data.month}
                        class="cursor-pointer group"
                      >
                        <!-- Background hover & select highlight -->
                        <rect
                          x={x - col_width / 2 + 2}
                          y="20"
                          width={col_width - 4}
                          height="156"
                          fill={if is_selected, do: "rgba(99, 102, 241, 0.08)", else: "transparent"}
                          class="group-hover:fill-slate-100/50 transition-colors"
                          rx="4"
                        />
                        
    <!-- Aktivasi Bar (Bottom) -->
                        <rect
                          x={x - bar_w / 2}
                          y={170 - akt_h}
                          width={bar_w}
                          height={akt_h}
                          fill={if is_selected, do: "#312e81", else: "#4f46e5"}
                          rx="2"
                          class="transition-all duration-300"
                        />
                        <!-- Reset Bar (Top) -->
                        <rect
                          x={x - bar_w / 2}
                          y={170 - akt_h - rst_h}
                          width={bar_w}
                          height={rst_h}
                          fill={if is_selected, do: "#581c87", else: "#a855f7"}
                          rx="2"
                          class="transition-all duration-300"
                        />
                        
    <!-- Tooltip-like small count text on top of the bars when selected/hovered -->
                        <%= if is_selected or (month_data.aktivasi + month_data.reset) > 0 do %>
                          <text
                            x={x}
                            y={170 - akt_h - rst_h - 6}
                            text-anchor="middle"
                            class={[
                              "text-[8px] font-bold font-mono",
                              if(is_selected,
                                do: "fill-indigo-700 font-extrabold text-[9px]",
                                else:
                                  "fill-slate-400 opacity-0 group-hover:opacity-100 transition-opacity"
                              )
                            ]}
                          >
                            {month_data.aktivasi + month_data.reset}
                          </text>
                        <% end %>
                        
    <!-- Label Month -->
                        <text
                          x={x}
                          y="195"
                          text-anchor="middle"
                          class={[
                            "text-[9px] font-black uppercase tracking-wider font-mono transition-colors",
                            if(is_selected, do: "fill-indigo-600", else: "fill-slate-500")
                          ]}
                        >
                          {format_month(month_data.month)}
                        </text>
                      </g>
                    <% end %>

                    <line x1="30" y1="170" x2="480" y2="170" stroke="#94a3b8" stroke-width="1.5" />
                  </svg>
                </div>
              </div>
              
    <!-- Proporsi Status (Donut Chart) -->
              <div class="lg:col-span-4 bg-white rounded-2xl shadow-lg border border-slate-100 p-8 flex flex-col justify-between">
                <div>
                  <h3 class="text-lg font-black text-slate-900 uppercase italic tracking-tight mb-1">
                    Proporsi <span class="text-indigo-600">Status</span>
                  </h3>
                  <p class="text-xs text-slate-400 font-bold uppercase tracking-widest">
                    Persetujuan Pengajuan
                  </p>
                </div>

                <%= if @tot > 0 do %>
                  <div class="flex items-center justify-center py-6">
                    <div class="relative w-40 h-40">
                      <svg viewBox="0 0 160 160" class="w-full h-full -rotate-90">
                        <circle
                          cx="80"
                          cy="80"
                          r="60"
                          fill="transparent"
                          stroke="#f1f5f9"
                          stroke-width="18"
                        />
                        <!-- Disetujui (emerald) -->
                        <circle
                          cx="80"
                          cy="80"
                          r="60"
                          fill="transparent"
                          stroke="#10b981"
                          stroke-width="18"
                          stroke-dasharray={@circ}
                          stroke-dashoffset={0}
                          style={"stroke-dasharray: #{@disetujui_len} #{@circ};"}
                        />
                        <!-- Pending (amber) -->
                        <circle
                          cx="80"
                          cy="80"
                          r="60"
                          fill="transparent"
                          stroke="#f59e0b"
                          stroke-width="18"
                          stroke-dasharray={@circ}
                          stroke-dashoffset={@pending_offset}
                          style={"stroke-dasharray: #{@pending_len} #{@circ};"}
                        />
                        <!-- Ditolak (rose) -->
                        <circle
                          cx="80"
                          cy="80"
                          r="60"
                          fill="transparent"
                          stroke="#f43f5e"
                          stroke-width="18"
                          stroke-dasharray={@circ}
                          stroke-dashoffset={@ditolak_offset}
                          style={"stroke-dasharray: #{@ditolak_len} #{@circ};"}
                        />
                      </svg>
                      <!-- Center Text -->
                      <div class="absolute inset-0 flex flex-col items-center justify-center">
                        <span class="text-2xl font-black text-slate-900">{@tot}</span>
                        <span class="text-[9px] font-black uppercase text-slate-400 tracking-widest">
                          Total
                        </span>
                      </div>
                    </div>
                  </div>

                  <div class="space-y-2.5">
                    <div class="flex justify-between items-center text-xs">
                      <div class="flex items-center gap-2 font-bold text-slate-600">
                        <span class="w-2.5 h-2.5 bg-emerald-500 rounded-full"></span>
                        <span>Disetujui</span>
                      </div>
                      <span class="font-mono font-black text-slate-900">
                        {@disetujui} ({@disetujui_pct}%)
                      </span>
                    </div>
                    <div class="flex justify-between items-center text-xs">
                      <div class="flex items-center gap-2 font-bold text-slate-600">
                        <span class="w-2.5 h-2.5 bg-amber-500 rounded-full"></span>
                        <span>Pending</span>
                      </div>
                      <span class="font-mono font-black text-slate-900">
                        {@pending} ({@pending_pct}%)
                      </span>
                    </div>
                    <div class="flex justify-between items-center text-xs">
                      <div class="flex items-center gap-2 font-bold text-slate-600">
                        <span class="w-2.5 h-2.5 bg-rose-500 rounded-full"></span>
                        <span>Ditolak</span>
                      </div>
                      <span class="font-mono font-black text-slate-900">
                        {@ditolak} ({@ditolak_pct}%)
                      </span>
                    </div>
                  </div>
                <% else %>
                  <div class="py-16 text-center text-slate-400 text-sm font-bold uppercase tracking-widest border border-dashed border-slate-200 rounded-2xl my-4">
                    Belum ada data
                  </div>
                <% end %>
              </div>
            </div>
            <!-- Analisis Kendala Terbanyak (Horizontal Bar) -->
            <div class="bg-white rounded-2xl shadow-lg border border-slate-100 p-8 mb-8">
              <div class="mb-6 flex justify-between items-center">
                <div>
                  <h3 class="text-lg font-black text-slate-900 uppercase italic tracking-tight">
                    Analisis <span class="text-rose-500">Kategori Kendala</span>
                  </h3>
                  <p class="text-xs text-slate-400 font-bold uppercase tracking-widest mt-0.5">
                    Jumlah Keluhan Mahasiswa Berdasarkan Kategori (Klik Kategori untuk Detail)
                  </p>
                </div>
                <%= if @selected_category do %>
                  <button
                    phx-click="select_category"
                    phx-value-category={@selected_category}
                    class="text-xs font-black uppercase text-indigo-600 hover:text-indigo-800 transition-colors"
                  >
                    Clear Filter
                  </button>
                <% end %>
              </div>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <%= for {cat_code, cat_label} <- @categories do %>
                  <% count = Map.get(@category_stats, cat_code, 0) %>
                  <% pct = if @max_category > 0, do: count / @max_category * 100, else: 0 %>
                  <div
                    phx-click="select_category"
                    phx-value-category={cat_code}
                    class={[
                      "space-y-2 cursor-pointer p-4 rounded-2xl border transition-all duration-300",
                      if(@selected_category == cat_code,
                        do: "bg-indigo-50/50 border-indigo-200 shadow-lg shadow-indigo-50",
                        else: "border-slate-100 hover:border-slate-200 hover:bg-slate-50/50"
                      )
                    ]}
                  >
                    <div class="flex justify-between items-center text-xs font-bold text-slate-700">
                      <span class={[
                        "uppercase tracking-wider transition-colors",
                        if(@selected_category == cat_code,
                          do: "text-indigo-700 font-black",
                          else: "text-slate-600"
                        )
                      ]}>
                        {cat_label}
                      </span>
                      <span class={[
                        "font-mono px-2.5 py-0.5 rounded-lg text-xs font-black border transition-colors",
                        if(@selected_category == cat_code,
                          do: "bg-indigo-600 text-white border-indigo-600",
                          else: "bg-slate-50 border-slate-200 text-slate-900"
                        )
                      ]}>
                        {count} Laporan
                      </span>
                    </div>
                    <div class="w-full bg-slate-100 h-3 rounded-full overflow-hidden shadow-inner mt-2">
                      <div
                        class={[
                          "h-full rounded-full transition-all duration-700 shadow-md",
                          if(@selected_category == cat_code,
                            do: "bg-indigo-600",
                            else: "bg-slate-400"
                          )
                        ]}
                        style={"width: #{pct}%"}
                      >
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>
            
    <!-- Detail Keluhan per Kategori Terpilih -->
            <%= if @selected_category do %>
              <div class="bg-white rounded-2xl shadow-lg border border-slate-100 p-8 mb-8 transition-all animate-in fade-in duration-300">
                <div class="flex justify-between items-center mb-6">
                  <div>
                    <h3 class="text-lg font-black text-slate-900 uppercase italic tracking-tight">
                      Daftar Detail Keluhan:
                      <span class="text-indigo-600">
                        {Enum.find(@categories, fn {code, _} -> code == @selected_category end)
                        |> elem(1)}
                      </span>
                    </h3>
                    <p class="text-xs text-slate-400 font-bold uppercase tracking-widest mt-0.5">
                      Menampilkan Keluhan Khusus Kategori Ini
                    </p>
                  </div>
                  <button
                    phx-click="select_category"
                    phx-value-category={@selected_category}
                    class="text-xs font-black uppercase text-rose-500 hover:text-rose-700 transition-colors flex items-center gap-1"
                  >
                    Tutup [X]
                  </button>
                </div>

                <div class="overflow-x-auto">
                  <table class="w-full text-left border-collapse">
                    <thead class="bg-slate-50/50 border-b border-slate-100">
                      <tr>
                        <th class="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">
                          Pelapor
                        </th>
                        <th class="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">
                          Subjek Keluhan
                        </th>
                        <th class="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">
                          Status
                        </th>
                        <th class="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">
                          Tanggal
                        </th>
                        <th class="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest text-right">
                          Aksi
                        </th>
                      </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50">
                      <%= for k <- @category_keluhans do %>
                        <tr class="hover:bg-slate-50/30 transition-all cursor-default">
                          <td class="px-6 py-4">
                            <div class="font-bold text-slate-900">{k.user.name}</div>
                            <div class="text-[10px] text-slate-400 font-mono font-medium">
                              {k.user.email}
                            </div>
                          </td>
                          <td class="px-6 py-4">
                            <div class="font-bold text-slate-800 uppercase italic text-sm tracking-tight">
                              {k.subject}
                            </div>
                            <div class="text-xs text-slate-500 line-clamp-1 italic">
                              "{k.description}"
                            </div>
                          </td>
                          <td class="px-6 py-4 text-center">
                            <span class={[
                              "px-3 py-1 rounded-[0.5rem] text-[9px] font-black uppercase tracking-widest border",
                              case k.status do
                                "baru" -> "bg-blue-50 text-blue-700 border-blue-200"
                                "diproses" -> "bg-amber-50 text-amber-700 border-amber-200"
                                "selesai" -> "bg-green-50 text-green-700 border-green-200"
                                _ -> "bg-slate-50 text-slate-700 border-slate-200"
                              end
                            ]}>
                              {format_status(k.status)}
                            </span>
                          </td>
                          <td class="px-6 py-4 text-center text-xs font-mono font-bold text-slate-500">
                            {Calendar.strftime(k.inserted_at, "%d %b %Y")}
                          </td>
                          <td class="px-6 py-4 text-right">
                            <a
                              href="/admin/keluhan"
                              class="px-4 py-2 bg-slate-900 hover:bg-rose-600 text-white rounded-xl transition-all text-[9px] font-black uppercase tracking-widest"
                            >
                              Tinjau
                            </a>
                          </td>
                        </tr>
                      <% end %>
                      <%= if Enum.empty?(@category_keluhans) do %>
                        <tr>
                          <td
                            colspan="5"
                            class="px-6 py-12 text-center text-slate-400 text-xs italic bg-slate-50/20"
                          >
                            Tidak ada keluhan dalam kategori ini untuk rentang tanggal terpilih.
                          </td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>
              </div>
            <% end %>/div>
            <div class="bg-white shadow rounded-lg px-4 py-5 sm:p-6 border border-slate-200">
              <h3 class="text-lg leading-6 font-medium text-slate-900 mb-4">
                Akses Cepat Tautan Manajerial
              </h3>

              <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                <a
                  href="/admin/pengajuan"
                  class="relative rounded-lg border border-slate-300 bg-white px-6 py-5 shadow-sm flex items-center space-x-3 hover:border-slate-400 hover:bg-slate-50 focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-indigo-500 transition-colors"
                >
                  <div class="flex-shrink-0 bg-indigo-50 p-3 rounded-lg text-indigo-600">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
                      />
                    </svg>
                  </div>

                  <div class="flex-1 min-w-0">
                    <span class="absolute inset-0" aria-hidden="true"></span>
                    <p class="text-sm font-medium text-slate-900">Validasi Pengajuan</p>

                    <p class="text-sm text-slate-500 truncate">Verifikasi akun dan KTM</p>
                  </div>
                </a>
                <a
                  href="/admin/keluhan"
                  class="relative rounded-lg border border-slate-300 bg-white px-6 py-5 shadow-sm flex items-center space-x-3 hover:border-slate-400 hover:bg-slate-50 focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-indigo-500 transition-colors"
                >
                  <div class="flex-shrink-0 bg-indigo-50 p-3 rounded-lg text-indigo-600">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                      />
                    </svg>
                  </div>

                  <div class="flex-1 min-w-0">
                    <span class="absolute inset-0" aria-hidden="true"></span>
                    <p class="text-sm font-medium text-slate-900">Keluhan Teknis</p>

                    <p class="text-sm text-slate-500 truncate">Tindak lanjut masalah portal</p>
                  </div>
                </a>
                <a
                  href="/admin/users"
                  class="relative rounded-lg border border-slate-300 bg-white px-6 py-5 shadow-sm flex items-center space-x-3 hover:border-slate-400 hover:bg-slate-50 focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-indigo-500 transition-colors"
                >
                  <div class="flex-shrink-0 bg-indigo-50 p-3 rounded-lg text-indigo-600">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
                      />
                    </svg>
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
