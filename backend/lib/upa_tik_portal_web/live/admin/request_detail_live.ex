defmodule UpaTikPortalWeb.Admin.RequestDetailLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  def mount(%{"id" => id}, session, socket) do
    request = Requests.get_request!(id)
    admin = UpaTikPortal.Accounts.get_user_from_session(session)

    default_msg =
      if request.request_type == "aktivasi" do
        "Akun Gmail kampus Anda telah aktif. Silakan lakukan aktivasi Autentikasi 2 Faktor (2FA) demi keamanan akun Anda. Ikuti petunjuk aktivasi selengkapnya melalui grup Telegram dengan memindai QR Code yang tertera di bawah ini."
      else
        "Password akun Gmail kampus Anda telah direset. Silakan login kembali dan lakukan aktivasi Autentikasi 2 Faktor (2FA) demi keamanan akun Anda. Ikuti petunjuk selengkapnya melalui grup Telegram dengan memindai QR Code yang tertera di bawah ini."
      end

    socket =
      socket
      |> assign(
        page_title: "Detail Pengajuan – Admin UPA TIK",
        request: request,
        notes: request.admin_notes || "",
        manual_otp: default_msg,
        sending_otp: false,
        otp_sent: false,
        current_user: admin
      )
      |> allow_upload(:telegram_qr,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: 1,
        max_file_size: 5_000_000
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <nav class="sticky top-4 z-50 bg-white/80 backdrop-blur-md shadow-sm border border-slate-200/60 transition-all mb-8 rounded-2xl mx-auto max-w-5xl px-4 sm:px-6">
      <div class="flex justify-between h-16">
        <div class="flex items-center gap-3">
          <div class="p-1 bg-white rounded-xl shadow-sm border border-slate-100 flex items-center justify-center">
            <img
              src={~p"/images/utm_logo.png"}
              class="h-8 w-auto hover:scale-105 transition-transform drop-shadow-sm"
              alt="UTM Logo"
            />
          </div>

          <span class="text-slate-900 font-extrabold text-lg tracking-tight uppercase italic">
            Admin <span class="text-indigo-600">Console</span>
          </span>
        </div>

        <div class="flex items-center space-x-1 sm:space-x-4">
          <a
            href="/admin"
            class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all"
          >
            Overview
          </a>
          <a
            href="/admin/pengajuan"
            class="px-4 py-2 rounded-xl text-indigo-600 bg-indigo-50 font-bold text-sm transition-all"
          >
            Pengajuan
          </a>
          <a
            href="/admin/keluhan"
            class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all"
          >
            Keluhan
          </a>
          <a
            href="/admin/users"
            class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all text-xs uppercase"
          >
            Users
          </a>
          <a
            href="/admin/logs"
            class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all text-xs uppercase"
          >
            Logs
          </a>
          <div class="w-px h-6 bg-slate-200 mx-1 hidden sm:block"></div>

          <a href="/auth/logout" class="p-2 text-slate-400 hover:text-rose-500 transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
              />
            </svg>
          </a>
        </div>
      </div>
    </nav>

    <div class="max-w-4xl mx-auto pb-24">
      <div class="bg-white rounded-[3rem] shadow-2xl shadow-slate-200/50 border border-slate-100 overflow-hidden relative">
        <div class="absolute top-0 right-0 w-64 h-64 bg-indigo-50/50 rounded-full blur-[80px] -translate-x-12 -translate-y-24">
        </div>

        <header class="bg-slate-900 px-12 py-10 text-white relative flex flex-col md:flex-row justify-between items-center gap-6">
          <div class="space-y-2">
            <h2 class="text-2xl font-black uppercase italic tracking-tight">
              Verifikasi <span class="text-indigo-400">Pengajuan</span>
            </h2>

            <div class="flex items-center gap-3">
              <span class="text-[10px] bg-white/10 px-3 py-1 rounded-lg font-black uppercase tracking-widest text-white/60">
                ID #{@request.id}
              </span>
              <span class="text-[10px] bg-white/10 px-3 py-1 rounded-lg font-black uppercase tracking-widest text-white/60">
                Dikirim: {Calendar.strftime(@request.inserted_at, "%d %b %Y %H:%M")}
              </span>
            </div>
          </div>

          <span class={[
            "px-6 py-2.5 rounded-2xl text-[10px] font-black uppercase tracking-[0.2em] shadow-xl",
            status_class(@request.status)
          ]}>
            {status_label(@request.status)}
          </span>
        </header>

        <div class="p-12 space-y-12">
          <section class="grid grid-cols-1 md:grid-cols-2 gap-12">
            <div class="space-y-8">
              <div class="group/field">
                <p class="text-[9px] font-black text-slate-300 uppercase tracking-[0.3em] mb-2 group-hover/field:text-indigo-600 transition-colors">
                  Personalitas Mahasiswa
                </p>

                <p class="text-2xl font-black text-slate-900 uppercase italic tracking-tight">
                  {@request.full_name}
                </p>

                <div class="flex items-center gap-2 mt-1">
                  <div class="w-1.5 h-1.5 bg-indigo-600 rounded-full animate-pulse"></div>

                  <p class="text-sm font-bold text-indigo-600 font-mono tracking-tighter uppercase">
                    NIM: {@request.nim}
                  </p>
                </div>
              </div>

              <div class="space-y-1">
                <p class="text-[9px] font-black text-slate-300 uppercase tracking-[0.3em] mb-2">
                  Peran Akun SSO
                </p>

                <div class="bg-slate-50 p-4 rounded-2xl border border-slate-100 italic font-bold text-slate-600 uppercase text-xs tracking-tight">
                  {@request.user.role} <br />
                  <span class="text-slate-400 text-[10px]">Terverifikasi Google Workspace</span>
                </div>
              </div>
            </div>

            <div class="space-y-8">
              <div class="p-8 bg-slate-900 rounded-[2.5rem] shadow-2xl shadow-indigo-100 text-white relative overflow-hidden group/target">
                <div class="absolute top-0 right-0 w-20 h-20 bg-indigo-500/20 rounded-full translate-x-8 -translate-y-8 blur-2xl group-hover/target:scale-150 transition-transform">
                </div>

                <p class="text-[9px] font-black text-white/40 uppercase tracking-[0.3em] mb-3">
                  Email Target Aktivasi
                </p>

                <p class="text-xl font-black text-indigo-300 font-mono tracking-tight break-all">
                  {@request.email_requested}
                </p>

                <div class="flex items-center gap-2 mt-4">
                  <span class="text-[9px] font-black px-3 py-1 bg-white/10 rounded-lg uppercase tracking-widest text-white/80">
                    {format_type(@request.request_type)}
                  </span>
                </div>
              </div>

              <div class="space-y-2">
                <p class="text-[9px] font-black text-slate-300 uppercase tracking-[0.3em] ml-1">
                  Kredensial Gmail SSO
                </p>

                <p class="text-sm font-bold text-slate-500 font-mono bg-slate-50 px-4 py-2 rounded-xl inline-block border border-slate-100">
                  {@request.user.email}
                </p>
              </div>
            </div>
          </section>

          <section class="space-y-6 pt-6 border-t border-slate-100">
            <p class="text-[9px] font-black text-slate-300 uppercase tracking-[0.3em]">
              Informasi Kontak Pemberitahuan
            </p>

            <div class="p-8 bg-slate-50 rounded-[2.5rem] border border-slate-100 relative overflow-hidden group/notification">
              <div class="absolute top-0 right-0 w-16 h-16 bg-emerald-500/10 rounded-full translate-x-6 -translate-y-6 blur-xl">
              </div>

              <p class="text-[9px] font-black text-slate-400 uppercase tracking-[0.3em] mb-2">
                Akun Gmail Aktif Mahasiswa
              </p>

              <p class="text-xl font-black text-slate-900 font-mono tracking-tight break-all flex items-center gap-2">
                <svg
                  class="w-6 h-6 text-indigo-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2.5"
                    d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                  />
                </svg>
                {@request.notification_email}
              </p>

              <p class="text-[10px] text-slate-400 font-medium mt-2 leading-relaxed">
                Kirimkan notifikasi kredensial ke email di atas jika akun kampus sudah siap/aktif.
              </p>
            </div>
          </section>

          <section class="space-y-6 pt-6 border-t border-slate-100">
            <p class="text-[9px] font-black text-slate-300 uppercase tracking-[0.3em]">
              Berkas Pendukung Terunggah
            </p>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
              <!-- Foto KTM -->
              <div class="p-6 bg-slate-50 border border-slate-100 rounded-[2rem] space-y-4">
                <p class="text-[9px] font-black text-slate-400 uppercase tracking-[0.3em]">
                  Foto Kartu Tanda Mahasiswa (KTM)
                </p>

                <%= if @request.ktm_photo_url do %>
                  <div class="relative group/ktm overflow-hidden rounded-2xl border border-slate-200 bg-white">
                    <img
                      src={@request.ktm_photo_url}
                      alt="KTM Mahasiswa"
                      class="w-full h-48 object-contain transition-transform duration-300 group-hover/ktm:scale-105"
                    />
                    <div class="absolute inset-0 bg-slate-900/60 opacity-0 group-hover/ktm:opacity-100 transition-opacity flex items-center justify-center">
                      <a
                        href={@request.ktm_photo_url}
                        target="_blank"
                        class="px-4 py-2 bg-white text-slate-900 font-bold rounded-xl text-xs hover:bg-indigo-50 transition-colors"
                      >
                        Lihat Ukuran Penuh
                      </a>
                    </div>
                  </div>
                <% else %>
                  <div class="py-12 text-center text-slate-400 text-sm border-2 border-dashed border-slate-200 rounded-2xl">
                    ⚠️ Foto KTM Tidak Tersedia
                  </div>
                <% end %>
              </div>
              <!-- Foto KHS -->
              <div class="p-6 bg-slate-50 border border-slate-100 rounded-[2rem] space-y-4">
                <p class="text-[9px] font-black text-slate-400 uppercase tracking-[0.3em]">
                  Foto Kartu Hasil Studi (KHS)
                </p>

                <%= if @request.khs_photo_url do %>
                  <div class="relative group/khs overflow-hidden rounded-2xl border border-slate-200 bg-white">
                    <img
                      src={@request.khs_photo_url}
                      alt="KHS Mahasiswa"
                      class="w-full h-48 object-contain transition-transform duration-300 group-hover/khs:scale-105"
                    />
                    <div class="absolute inset-0 bg-slate-900/60 opacity-0 group-hover/khs:opacity-100 transition-opacity flex items-center justify-center">
                      <a
                        href={@request.khs_photo_url}
                        target="_blank"
                        class="px-4 py-2 bg-white text-slate-900 font-bold rounded-xl text-xs hover:bg-indigo-50 transition-colors"
                      >
                        Lihat Ukuran Penuh
                      </a>
                    </div>
                  </div>
                <% else %>
                  <div class="py-12 text-center text-slate-400 text-sm border-2 border-dashed border-slate-200 rounded-2xl">
                    ⚠️ Foto KHS Tidak Tersedia
                  </div>
                <% end %>
              </div>
            </div>
          </section>

          <%= if @request.status == "pending" do %>
            <section class="pt-8 border-t border-slate-100 flex flex-col sm:flex-row gap-4">
              <button
                phx-click="approve"
                class="flex-1 py-6 bg-slate-900 text-white font-black rounded-3xl shadow-2xl shadow-slate-200 hover:bg-emerald-600 hover:shadow-emerald-100 transition-all duration-300 flex items-center justify-center gap-3 uppercase text-xs tracking-[0.2em] group/approve"
              >
                <svg
                  class="w-5 h-5 group-hover/approve:scale-125 transition-transform"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="3"
                    d="M5 13l4 4L19 7"
                  />
                </svg>
                <span>Setujui Permohonan</span>
              </button>
              <button
                phx-click="reject"
                class="flex-1 py-6 bg-white border-2 border-rose-500 text-rose-500 font-black rounded-3xl hover:bg-rose-500 hover:text-white transition-all duration-300 flex items-center justify-center gap-3 uppercase text-xs tracking-[0.2em] group/reject"
              >
                <svg
                  class="w-5 h-5 group-hover/reject:rotate-90 transition-transform"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="3"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
                <span>Tolak Pengajuan</span>
              </button>
            </section>
          <% end %>

          <%= if @request.status == "disetujui" do %>
            <section class="pt-8 border-t border-slate-100 space-y-6">
              <div class="bg-indigo-50 p-8 rounded-[2.5rem] border border-indigo-100 shadow-sm">
                <div class="flex items-center gap-4 mb-6">
                  <div class="w-12 h-12 bg-white rounded-2xl flex items-center justify-center text-indigo-600 shadow-lg shadow-indigo-100/50">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2.5"
                        d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                      />
                    </svg>
                  </div>

                  <div>
                    <h4 class="text-sm font-black text-indigo-900 uppercase tracking-widest italic">
                      Panel Kirim Kredensial ke Gmail
                    </h4>

                    <p class="text-xs font-medium text-indigo-400">
                      Kirim ke:
                      <span class="font-bold text-indigo-600 underline">
                        {@request.notification_email}
                      </span>
                    </p>
                  </div>
                </div>

                <.form
                  for={%{}}
                  phx-submit="send-otp"
                  phx-change="update-field"
                  class="space-y-6"
                  id="send-credentials-form"
                >
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Pesan Pemberitahuan Kredensial -->
                    <div class="space-y-2">
                      <label class="block text-xs font-black text-indigo-900 uppercase tracking-widest ml-1">
                        Pesan Pemberitahuan Kredensial / Status
                      </label>
                      <textarea
                        name="manual_otp"
                        rows="3"
                        placeholder="Contoh: Akun Gmail Anda sudah aktif..."
                        class="w-full px-6 py-4 bg-white border border-indigo-100 rounded-2xl text-sm font-bold text-indigo-900 placeholder:text-indigo-200 focus:ring-4 focus:ring-indigo-100 outline-none transition-all resize-none font-sans"
                      ><%= @manual_otp %></textarea>
                    </div>
                    <!-- Upload QR Code Telegram -->
                    <div class="space-y-2">
                      <label class="block text-xs font-black text-indigo-900 uppercase tracking-widest ml-1">
                        Upload Gambar QR Code Telegram
                      </label>
                      <div
                        class="border border-dashed border-indigo-200 rounded-2xl p-4 bg-white hover:bg-indigo-50/30 transition-all text-center relative"
                        phx-drop-target={@uploads.telegram_qr.ref}
                      >
                        <.live_file_input upload={@uploads.telegram_qr} class="sr-only" />
                        <%= for entry <- @uploads.telegram_qr.entries do %>
                          <div class="flex items-center justify-between gap-2 text-xs">
                            <span class="font-bold text-indigo-900 truncate max-w-[150px]">
                              {entry.client_name}
                            </span>
                            <div class="flex items-center gap-2">
                              <span class="text-[10px] text-indigo-500 font-bold">
                                {entry.progress}%
                              </span>
                              <button
                                type="button"
                                phx-click="cancel-upload"
                                phx-value-ref={entry.ref}
                                class="text-rose-500 hover:text-rose-700 font-black"
                              >
                                ✕
                              </button>
                            </div>
                          </div>
                        <% end %>

                        <%= if Enum.empty?(@uploads.telegram_qr.entries) do %>
                          <label
                            for={@uploads.telegram_qr.ref}
                            class="cursor-pointer block text-xs text-indigo-400 font-semibold py-1"
                          >
                            📷 Klik untuk pilih/tarik QR Code
                          </label>
                        <% end %>
                      </div>
                    </div>
                  </div>

                  <button
                    type="submit"
                    class="w-full py-4 bg-slate-900 text-white font-black rounded-2xl hover:bg-indigo-600 transition-all shadow-xl shadow-indigo-100 uppercase text-xs tracking-widest disabled:opacity-50"
                    disabled={@sending_otp}
                  >
                    {if @sending_otp, do: "Mengirim...", else: "Kirim Kredensial"}
                  </button>
                </.form>

                <%= if @otp_sent do %>
                  <p class="mt-4 text-emerald-600 text-xs font-black uppercase tracking-widest flex items-center gap-2">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="3"
                        d="M5 13l4 4L19 7"
                      />
                    </svg>
                    Terakhir Terkirim: {Calendar.strftime(@request.updated_at, "%H:%M")}
                  </p>
                <% end %>
              </div>
            </section>
          <% end %>

          <section class="pt-8 border-t border-slate-100">
            <div class="bg-slate-50 p-10 rounded-[2.5rem] border border-slate-100">
              <div class="flex justify-between items-center mb-6">
                <h4 class="text-xs font-black text-slate-900 uppercase tracking-[0.2em] italic">
                  Catatan Administratif
                </h4>

                <button
                  phx-click="save-notes"
                  class="text-[9px] font-black uppercase tracking-widest px-4 py-2 bg-slate-900 text-white rounded-xl hover:bg-slate-700 transition-all shadow-lg"
                >
                  Simpan Catatan
                </button>
              </div>
              <textarea
                phx-change="update-field"
                name="notes"
                rows="4"
                placeholder="Tuliskan catatan internal atau instruksi khusus di sini..."
                class="w-full px-8 py-6 bg-white border border-slate-200 rounded-[2rem] text-sm font-bold text-slate-700 focus:ring-8 focus:ring-slate-100 focus:border-slate-400 outline-none transition-all shadow-inner resize-none italic"
              ><%= @notes %></textarea>
            </div>
          </section>
        </div>
      </div>

      <div class="flex justify-center mt-12">
        <a
          href="/admin/pengajuan"
          class="flex items-center gap-3 px-8 py-3 bg-white border border-slate-200 rounded-2xl text-xs font-black text-slate-400 uppercase tracking-widest hover:text-slate-900 hover:border-slate-900 transition-all shadow-sm group"
        >
          <svg
            class="w-4 h-4 group-hover:-translate-x-1 transition-transform"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="3"
              d="M10 19l-7-7m0 0l7-7m-7 7h18"
            />
          </svg>
          <span>Kembali ke Indeks</span>
        </a>
      </div>
    </div>
    """
  end

  def handle_event("approve", _params, socket) do
    case Requests.update_status(socket.assigns.request, "disetujui", socket.assigns.notes) do
      {:ok, updated} ->
        actor = socket.assigns.current_user

        UpaTikPortal.AuditLogs.log_action(
          actor.id,
          "approve_request",
          "email_request",
          updated.id,
          "Menyetujui pengajuan #{updated.request_type} akun #{updated.email_requested} milik #{updated.full_name}"
        )

        {:noreply,
         socket
         |> assign(request: updated)
         |> put_flash(:info, "PENGATURAN STATUS: Pengajuan BERHASIL Disetujui.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengupdate status.")}
    end
  end

  def handle_event("reject", _params, socket) do
    case Requests.update_status(socket.assigns.request, "ditolak", socket.assigns.notes) do
      {:ok, updated} ->
        actor = socket.assigns.current_user

        UpaTikPortal.AuditLogs.log_action(
          actor.id,
          "reject_request",
          "email_request",
          updated.id,
          "Menolak pengajuan #{updated.request_type} akun #{updated.email_requested} milik #{updated.full_name}"
        )

        {:noreply,
         socket
         |> assign(request: updated)
         |> put_flash(:info, "PENGATURAN STATUS: Pengajuan Telah Ditolak.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengupdate status.")}
    end
  end

  def handle_event("save-notes", _params, socket) do
    request = socket.assigns.request
    notes = socket.assigns.notes

    case Requests.update_admin_notes(request, notes) do
      {:ok, updated} ->
        actor = socket.assigns.current_user

        UpaTikPortal.AuditLogs.log_action(
          actor.id,
          "update_notes",
          "email_request",
          request.id,
          "Memperbarui catatan administratif untuk pengajuan milik #{request.full_name} (NIM: #{request.nim})"
        )

        {:noreply,
         socket
         |> assign(request: updated)
         |> put_flash(:info, "PENGATURAN CATATAN: Catatan administratif BERHASIL disimpan.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal menyimpan catatan.")}
    end
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :telegram_qr, ref)}
  end

  def handle_event("update-field", params, socket) do
    field_name = List.first(params["_target"] || [])

    case field_name do
      "notes" -> {:noreply, assign(socket, notes: params["notes"])}
      "manual_otp" -> {:noreply, assign(socket, manual_otp: params["manual_otp"])}
      "telegram_qr" -> {:noreply, socket}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("send-otp", params, socket) do
    manual_otp = Map.get(params, "manual_otp", socket.assigns.manual_otp)
    request = socket.assigns.request

    if request.status != "disetujui" do
      {:noreply, put_flash(socket, :error, "ERROR: Setujui pengajuan terlebih dahulu.")}
    else
      socket = assign(socket, sending_otp: true, manual_otp: manual_otp)

      # Consume uploaded Telegram QR code if any
      telegram_qr_url =
        try do
          case consume_uploaded_entries(socket, :telegram_qr, &save_upload/2) do
            [{:ok, url} | _] -> url
            [url | _] when is_binary(url) -> url
            _ -> request.telegram_qr_url
          end
        rescue
          _ -> request.telegram_qr_url
        end

      # Use manual_otp if provided, else default to dynamic message
      default_msg =
        if request.request_type == "aktivasi" do
          "Akun Gmail kampus Anda telah aktif. Silakan lakukan aktivasi Autentikasi 2 Faktor (2FA) demi keamanan akun Anda. Ikuti petunjuk aktivasi selengkapnya melalui grup Telegram dengan memindai QR Code yang tertera di bawah ini."
        else
          "Password akun Gmail kampus Anda telah direset. Silakan login kembali dan lakukan aktivasi Autentikasi 2 Faktor (2FA) demi keamanan akun Anda. Ikuti petunjuk selengkapnya melalui grup Telegram dengan memindai QR Code yang tertera di bawah ini."
        end

      otp = if manual_otp != "" and not is_nil(manual_otp), do: manual_otp, else: default_msg
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      changeset =
        Ecto.Changeset.change(request, %{
          otp_code: otp,
          otp_sent_at: now,
          telegram_qr_url: telegram_qr_url
        })

      case UpaTikPortal.Repo.update(changeset) do
        {:ok, updated_request} ->
          email = UpaTikPortal.Emails.otp_email(updated_request)

          case deliver_now(email) do
            {:ok, _} ->
              actor = socket.assigns.current_user

              UpaTikPortal.AuditLogs.log_action(
                actor.id,
                "send_credentials",
                "email_request",
                updated_request.id,
                "Mengirim kredensial/OTP ke email notifikasi #{updated_request.notification_email} untuk #{updated_request.full_name}"
              )

              {:noreply,
               socket
               |> assign(
                 request: updated_request,
                 sending_otp: false,
                 otp_sent: true,
                 manual_otp: default_msg
               )
               |> put_flash(:info, "SUKSES: Kredensial Berhasil Dikirim!")}

            {:error, reason} ->
              IO.inspect(reason, label: "SEND ERROR")

              {:noreply,
               assign(socket, sending_otp: false)
               |> put_flash(:error, "Gagal kirim email: #{inspect(reason)}")}
          end

        {:error, _} ->
          {:noreply,
           assign(socket, sending_otp: false)
           |> put_flash(:error, "Gagal update OTP di database.")}
      end
    end
  end

  defp save_upload(%{path: tmp_path}, entry) do
    ext = Path.extname(entry.client_name)
    filename = "#{:crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)}#{ext}"

    content_type =
      case String.downcase(ext) do
        ".jpg" -> "image/jpeg"
        ".jpeg" -> "image/jpeg"
        ".png" -> "image/png"
        ".webp" -> "image/webp"
        _ -> "application/octet-stream"
      end

    minio_configured? =
      System.get_env("MINIO_ACCESS_KEY") != nil or
        System.get_env("AWS_ACCESS_KEY_ID") != nil

    if minio_configured? do
      try do
        bucket = Application.get_env(:waffle, :bucket, "upa-tik-uploads")
        s3_config = Application.get_env(:ex_aws, :s3, [])
        host = Keyword.get(s3_config, :host, System.get_env("MINIO_HOST", "127.0.0.1"))

        s3_bucket =
          if String.contains?(host, "supabase.co") and not String.contains?(bucket, "storage/v1/s3") do
            "storage/v1/s3/#{bucket}"
          else
            bucket
          end

        file_content = File.read!(tmp_path)

        case ExAws.S3.put_object(s3_bucket, filename, file_content, content_type: content_type)
             |> ExAws.request() do
          {:ok, _} ->
            s3_config = Application.get_env(:ex_aws, :s3, [])
            host = Keyword.get(s3_config, :host, System.get_env("MINIO_HOST", "127.0.0.1"))
            port = Keyword.get(s3_config, :port)

            endpoint = System.get_env("MINIO_ENDPOINT")

            url =
              cond do
                endpoint ->
                  "#{String.trim_trailing(endpoint, "/")}/#{bucket}/#{filename}"

                port in [nil, 80, 443] ->
                  scheme = if port == 443 || String.contains?(host, "supabase") || String.contains?(host, "r2"), do: "https", else: "http"
                  "#{scheme}://#{host}/#{bucket}/#{filename}"

                true ->
                  "http://#{host}:#{port}/#{bucket}/#{filename}"
              end

            {:ok, url}

          {:error, reason} ->
            IO.warn("[MinIO Upload GAGAL] Reason: #{inspect(reason)}")
            save_local(tmp_path, filename)
        end
      rescue
        _ -> save_local(tmp_path, filename)
      end
    else
      save_local(tmp_path, filename)
    end
  end

  defp save_local(tmp_path, filename) do
    uploads_dir = Path.join(:code.priv_dir(:upa_tik_portal), "static/uploads")
    File.mkdir_p!(uploads_dir)
    dest = Path.join(uploads_dir, filename)
    File.cp!(tmp_path, dest)
    {:ok, "/uploads/#{filename}"}
  end

  # MESIN PENGIRIM INTERNAL - PORT 587 FIX
  defp deliver_now(email) do
    user = System.get_env("SMTP_USER")
    pass = System.get_env("SMTP_PASSWORD")

    # Kita gunakan Port 587 + STARTTLS (tls: :always)
    # Ini biasanya lebih sukses di Windows daripada Port 465
    config = [
      relay: "smtp.gmail.com",
      username: user,
      password: pass,
      port: 587,
      ssl: false,
      tls: :always,
      auth: :always,
      retries: 1,
      tls_options: [verify: :verify_none],
      ssl_options: [verify: :verify_none]
    ]

    IO.puts(">>> [INTERNAL] Mengirim via Port 587 (STARTTLS)...")
    Swoosh.Adapters.SMTP.deliver(email, config)
  end

  defp status_class("pending"), do: "bg-amber-100 text-amber-700 border border-amber-200"
  defp status_class("disetujui"), do: "bg-emerald-100 text-emerald-700 border border-emerald-200"
  defp status_class("ditolak"), do: "bg-rose-100 text-rose-700 border border-rose-200"
  defp status_class(_), do: "bg-slate-100 text-slate-700"

  defp status_label("pending"), do: "⏳ Menunggu"
  defp status_label("disetujui"), do: "✅ Disetujui"
  defp status_label("ditolak"), do: "❌ Ditolak"
  defp status_label(s), do: s

  defp format_type("aktivasi"), do: "Aktivasi Akun"
  defp format_type("reset"), do: "Reset Password"
  defp format_type(t), do: t
end
