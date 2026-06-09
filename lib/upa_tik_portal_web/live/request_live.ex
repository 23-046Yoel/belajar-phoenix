defmodule UpaTikPortalWeb.RequestLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  @max_file_size 5_000_000

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = UpaTikPortal.Accounts.get_user!(user_id)

    socket =
      socket
      |> assign(page_title: "Pengajuan Bermasalah – UPA TIK Portal")
      |> assign(current_user: user)
      |> assign(request_type: "aktivasi")
      |> assign(nim: "")
      |> assign(full_name: "")
      |> assign(email_requested: "")
      |> assign(notification_email: "")
      |> assign(errors: %{})
      |> assign(submitted: false)

    {:ok, socket}
  end

  def handle_event("set_type", %{"type" => type}, socket) do
    {:noreply, assign(socket, request_type: type)}
  end

  def handle_event("update_field", %{"_target" => ["ktm_photo"]}, socket) do
    # Ignore file changes in this handler; LiveView handles @uploads automatically.
    {:noreply, socket}
  end

  def handle_event("update_field", params, socket) do
    # Phoenix sends %{"field_name" => "value", "_target" => ["field_name"]}
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
      "request_type" => socket.assigns.request_type,
      "nim" => socket.assigns.nim,
      "full_name" => socket.assigns.full_name,
      "email_requested" => socket.assigns.email_requested,
      "notification_email" => socket.assigns.notification_email
    }

    case Requests.create_request(user.id, attrs) do
      {:ok, _request} ->
        {:noreply,
         socket
         |> assign(submitted: true)
         |> put_flash(:info, "Pengajuan berhasil dikirim!")}

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)

        {:noreply, assign(socket, errors: errors)}
    end
  end

  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(submitted: false, nim: "", full_name: "", email_requested: "", errors: %{})}
  end

  defp save_upload(%{path: tmp_path}, entry) do
    ext = Path.extname(entry.client_name)
    filename = "#{:crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)}#{ext}"

    content_type = case String.downcase(ext) do
      ".jpg" -> "image/jpeg"
      ".jpeg" -> "image/jpeg"
      ".png" -> "image/png"
      ".webp" -> "image/webp"
      _ -> "application/octet-stream"
    end

    # Cek apakah MinIO dikonfigurasi (ada access key di env)
    minio_configured? =
      System.get_env("MINIO_ACCESS_KEY") != nil or
      System.get_env("AWS_ACCESS_KEY_ID") != nil

    if minio_configured? do
      # Coba upload ke MinIO/S3
      try do
        bucket = Application.get_env(:waffle, :bucket, "upa-tik-uploads")
        file_content = File.read!(tmp_path)

        case ExAws.S3.put_object(bucket, filename, file_content, content_type: content_type)
             |> ExAws.request() do
          {:ok, _} ->
            s3_config = Application.get_env(:ex_aws, :s3, [])
            host = Keyword.get(s3_config, :host, System.get_env("MINIO_HOST", "127.0.0.1"))
            port = Keyword.get(s3_config, :port, (System.get_env("MINIO_PORT") || "9000") |> String.to_integer())
            {:ok, "http://#{host}:#{port}/#{bucket}/#{filename}"}

          {:error, reason} ->
            IO.warn("[MinIO Upload GAGAL] Reason: #{inspect(reason)}")
            save_local(tmp_path, filename)
        end
      rescue
        _ -> save_local(tmp_path, filename)
      end
    else
      # MinIO tidak dikonfigurasi, langsung simpan lokal (tanpa retry / delay)
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

  def render(assigns) do
    ~H"""
    <%!-- <nav class="sticky top-4 z-50 bg-white/80 backdrop-blur-md shadow-sm border border-slate-200/60 transition-all mb-8 rounded-2xl mx-auto max-w-5xl px-4 sm:px-6">
      <div class="flex justify-between h-16">
        <div class="flex items-center gap-3">
          <div class="p-1 bg-white rounded-xl shadow-sm border border-slate-100 flex items-center justify-center">
            <img src={~p"/images/utm_logo.png"} class="h-8 w-auto hover:scale-105 transition-transform drop-shadow-sm" alt="UTM Logo">
          </div>
          <span class="text-slate-900 font-extrabold text-lg tracking-tight">UPA TIK <span class="text-indigo-600">Portal</span></span>
        </div>
        <div class="flex items-center space-x-1 sm:space-x-4">
          <a href="/portal/ajukan" class="px-4 py-2 rounded-xl text-indigo-600 bg-indigo-50 font-bold text-sm transition-all">Pengajuan</a>
          <a href="/portal/status" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Status</a>
          <a href="/portal/keluhan" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Lapor</a>
          <div class="w-px h-6 bg-slate-200 mx-2 hidden sm:block"></div>
          <a href="/auth/logout" class="p-2 text-slate-400 hover:text-rose-500 transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
          </a>
        </div>
      </div>
    </nav> --%>
    <.navbar active_tab={:ajukan} current_user={@current_user}>

    <div class="max-w-4xl mx-auto space-y-12 pb-20">
      <div class="text-center space-y-3">
        <h1 class="text-4xl font-extrabold text-slate-900 dark:text-white tracking-tight sm:text-5xl uppercase italic">
          Pengajuan <span class="text-indigo-600">Aktivasi</span>
        </h1>
        <p class="text-slate-500 dark:text-white text-lg font-medium max-w-2xl mx-auto">Lengkapi data di bawah ini untuk pemrosesan akun email kampus Anda secara profesional.</p>
      </div>

      <%= if @submitted do %>
        <div class="bg-white border border-slate-100 rounded-[2.5rem] p-16 text-center shadow-2xl shadow-indigo-100/50 animate-in fade-in zoom-in duration-500">
          <div class="w-24 h-24 bg-green-50 rounded-full flex items-center justify-center mx-auto mb-8 shadow-inner">
            <svg class="w-12 h-12 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/>
            </svg>
          </div>
          <h2 class="text-3xl font-black text-slate-900 mb-3 tracking-tight">Berhasil Terkirim!</h2>
          <p class="text-slate-500 mb-10 text-lg font-medium">Data Anda telah masuk ke sistem antrean kami. Mohon tunggu proses verifikasi.</p>
          <div class="flex flex-col sm:flex-row justify-center gap-4">
            <a href="/portal/status" class="px-10 py-4 bg-indigo-600 text-white rounded-2xl font-bold hover:bg-indigo-700 transition-all shadow-lg shadow-indigo-200 flex items-center justify-center gap-2">
              <span>Pantau Status</span>
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
            </a>
            <button phx-click="reset" class="px-10 py-4 bg-slate-50 text-slate-600 rounded-2xl font-bold hover:bg-slate-100 transition-all border border-slate-200">
              Buat Pengajuan Baru
            </button>
          </div>
        </div>
      <% else %>
        <div class="bg-white rounded-[2.5rem] shadow-2xl shadow-slate-200/50 border border-slate-100 overflow-hidden">
          <form id="request-form" phx-submit="submit" phx-change="update_field" class="p-8 sm:p-14 space-y-12">
            <div class="space-y-6">
              <div class="flex items-center gap-3">
                <span class="w-8 h-8 bg-indigo-600 text-white rounded-lg flex items-center justify-center font-bold text-sm">01</span>
                <label class="text-lg font-black text-slate-900 tracking-tight uppercase">Tipe Layanan</label>
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                <button type="button" phx-click="set_type" phx-value-type="aktivasi"
                  class={["relative group p-6 rounded-3xl border-2 text-left transition-all duration-300",
                    if(@request_type == "aktivasi", do: "border-indigo-600 bg-indigo-50/50 shadow-lg shadow-indigo-100", else: "border-slate-100 hover:border-indigo-200 hover:bg-slate-50")]}>
                  <div class={["w-10 h-10 rounded-xl flex items-center justify-center mb-4 transition-colors", if(@request_type == "aktivasi", do: "bg-indigo-600 text-white", else: "bg-slate-100 text-slate-400 group-hover:bg-indigo-100 group-hover:text-indigo-600")]}>
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                  </div>
                  <p class="font-black text-slate-900 text-lg tracking-tight">Aktivasi Baru</p>
                  <p class="text-sm text-slate-500 mt-1 font-medium leading-relaxed">Belum pernah memiliki akun email institusi @mahasiswa.trunojoyo.ac.id</p>
                </button>
                <button type="button" phx-click="set_type" phx-value-type="reset"
                  class={["relative group p-6 rounded-3xl border-2 text-left transition-all duration-300",
                    if(@request_type == "reset", do: "border-indigo-600 bg-indigo-50/50 shadow-lg shadow-indigo-100", else: "border-slate-100 hover:border-indigo-200 hover:bg-slate-50")]}>
                  <div class={["w-10 h-10 rounded-xl flex items-center justify-center mb-4 transition-colors", if(@request_type == "reset", do: "bg-indigo-600 text-white", else: "bg-slate-100 text-slate-400 group-hover:bg-indigo-100 group-hover:text-indigo-600")]}>
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/></svg>
                  </div>
                  <p class="font-black text-slate-900 text-lg tracking-tight">Reset Password</p>
                  <p class="text-sm text-slate-500 mt-1 font-medium leading-relaxed">Lupa password atau terkendala login ke akun email kampus yang sudah ada.</p>
                </button>
              </div>
            </div>

            <div class="space-y-8 pt-10 border-t border-slate-100">
              <div class="flex items-center gap-3">
                <span class="w-8 h-8 bg-indigo-600 text-white rounded-lg flex items-center justify-center font-bold text-sm">02</span>
                <label class="text-lg font-black text-slate-900 tracking-tight uppercase">Data Identitas</label>
              </div>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div class="space-y-2">
                  <label class="block text-xs font-black text-slate-400 uppercase tracking-widest ml-1">NIM Mahasiswa</label>
                  <input type="text" name="nim" value={@nim} placeholder="Contoh: 210411100001" required
                    class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-4 focus:ring-indigo-50 focus:border-indigo-600 focus:bg-white outline-none transition-all font-bold text-slate-900 placeholder:text-slate-300"/>
                  <%= if @errors[:nim] do %><p class="text-rose-500 text-xs font-bold mt-1 px-1">⚠️ <%= hd(@errors[:nim]) %></p><% end %>
                </div>

                <div class="space-y-2">
                  <label class="block text-xs font-black text-slate-400 uppercase tracking-widest ml-1">Nama Lengkap</label>
                  <input type="text" name="full_name" value={@full_name} placeholder="Sesuai Kartu Tanda Mahasiswa" required
                    class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-4 focus:ring-indigo-50 focus:border-indigo-600 focus:bg-white outline-none transition-all font-bold text-slate-900 placeholder:text-slate-300"/>
                  <%= if @errors[:full_name] do %><p class="text-rose-500 text-xs font-bold mt-1 px-1">⚠️ <%= hd(@errors[:full_name]) %></p><% end %>
                </div>

                <div class="md:col-span-2 space-y-2">
                  <label class="block text-xs font-black text-slate-400 uppercase tracking-widest ml-1">Email Institusi yang Diinginkan</label>
                  <div class="relative">
                    <input type="email" name="email_requested" value={@email_requested} placeholder="namaanda@mahasiswa.trunojoyo.ac.id" required
                      class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-4 focus:ring-indigo-50 focus:border-indigo-600 focus:bg-white outline-none transition-all font-bold text-slate-900 placeholder:text-slate-300 pl-14"/>
                    <div class="absolute left-5 top-1/2 -translate-y-1/2 text-slate-400">
                      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.206"/></svg>
                    </div>
                  </div>
                  <%= if @errors[:email_requested] do %><p class="text-rose-500 text-xs font-bold mt-1 px-1">⚠️ <%= hd(@errors[:email_requested]) %></p><% end %>
                  <p class="text-[10px] text-slate-400 font-medium px-1">Gunakan format <span class="text-indigo-600">nim@mahasiswa.trunojoyo.ac.id</span> untuk kemudahan sistem.</p>
                </div>
              </div>
            </div>

            <div class="space-y-8 pt-10 border-t border-slate-100">
              <div class="flex items-center gap-3">
                <span class="w-8 h-8 bg-indigo-600 text-white rounded-lg flex items-center justify-center font-bold text-sm">03</span>
                <label class="text-lg font-black text-slate-900 tracking-tight uppercase">Pemberitahuan</label>
              </div>

              <div class="space-y-2">
                <label class="block text-xs font-black text-slate-400 uppercase tracking-widest ml-1">Akun Gmail Aktif untuk Notifikasi</label>
                <div class="relative">
                  <input type="email" name="notification_email" value={@notification_email} placeholder="namaanda@gmail.com" required
                    class="w-full px-6 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-4 focus:ring-indigo-50 focus:border-indigo-600 focus:bg-white outline-none transition-all font-bold text-slate-900 placeholder:text-slate-300 pl-14"/>
                  <div class="absolute left-5 top-1/2 -translate-y-1/2 text-slate-400">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
                  </div>
                </div>
                <%= if @errors[:notification_email] do %><p class="text-rose-500 text-xs font-bold mt-1 px-1">⚠️ <%= hd(@errors[:notification_email]) %></p><% end %>
                <p class="text-[10px] text-slate-400 font-medium px-1">Masukkan akun Gmail aktif Anda sebagai pemberitahuan jika akun Gmail kampus Anda sudah selesai diaktifkan/direset.</p>
              </div>
            </div>

            <div class="pt-6">
              <button type="submit"
                class="w-full py-6 bg-indigo-600 text-white font-black text-lg rounded-[2rem] shadow-2xl shadow-indigo-200 hover:bg-indigo-700 hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center justify-center gap-3 group">
                <span>Kirim Pengajuan Sekarang</span>
                <svg class="w-6 h-6 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 7l5 5m0 0l-5 5m5-5H6"/></svg>
              </button>
              <p class="text-center text-[10px] text-slate-400 font-bold uppercase tracking-[0.2em] mt-6">Data yang dikirim akan dijaga kerahasiaannya oleh UPA TIK UTM</p>
            </div>
          </form>
        </div>
      <% end %>
    </div>
    </.navbar>
    """
  end

  defp upload_error_to_string(:too_large), do: "File terlalu besar (maks. 5MB)"
  defp upload_error_to_string(:too_many_files), do: "Hanya boleh 1 file"
  defp upload_error_to_string(:not_accepted), do: "Format tidak didukung (JPG/PNG/WEBP)"
end
