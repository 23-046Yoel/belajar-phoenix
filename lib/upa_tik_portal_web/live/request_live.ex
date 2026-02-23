defmodule UpaTikPortalWeb.RequestLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  @max_file_size 5_000_000

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = UpaTikPortal.Accounts.get_user!(user_id)

    socket =
      socket
      |> assign(page_title: "Ajukan Permintaan – UPA TIK Portal")
      |> assign(current_user: user)
      |> assign(request_type: "aktivasi")
      |> assign(nim: "")
      |> assign(full_name: "")
      |> assign(email_requested: "")
      |> assign(errors: %{})
      |> assign(submitted: false)
      |> allow_upload(:ktm_photo,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: 1,
        max_file_size: @max_file_size,
        auto_upload: true
      )

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

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :ktm_photo, ref)}
  end

  def handle_event("submit", _params, socket) do
    user = socket.assigns.current_user

    # Safe upload handling: only consume if there are entries and ALL are done.
    # consume_uploaded_entries will crash if called while any entry is in progress.
    ktm_url =
      if Enum.all?(socket.assigns.uploads.ktm_photo.entries, &(&1.done?)) do
        case consume_uploaded_entries(socket, :ktm_photo, &save_upload/2) do
          [path | _] -> path
          [] -> nil
        end
      else
        nil
      end

    attrs = %{
      "request_type" => socket.assigns.request_type,
      "nim" => socket.assigns.nim,
      "full_name" => socket.assigns.full_name,
      "email_requested" => socket.assigns.email_requested,
      "ktm_photo_url" => ktm_url
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
    dest_dir = Path.join([:code.priv_dir(:upa_tik_portal), "static", "uploads"])
    File.mkdir_p!(dest_dir)
    dest = Path.join(dest_dir, filename)
    File.cp!(tmp_path, dest)
    {:ok, "/uploads/#{filename}"}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50" data-theme="light">
      <!-- Navbar -->
      <nav class="bg-white border-b border-slate-200 shadow-sm">
        <div class="max-w-5xl mx-auto px-4 h-16 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <div class="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"/>
              </svg>
            </div>
            <span class="font-bold text-slate-800">UPA TIK Portal</span>
          </div>
          <div class="flex items-center gap-4">
            <a href="/portal/status" class="text-sm text-blue-600 hover:text-blue-800 font-medium transition-colors">
              Status Pengajuan
            </a>
            <a href="/auth/logout" class="text-sm text-slate-500 hover:text-red-600 transition-colors">Logout</a>
          </div>
        </div>
      </nav>

      <div class="max-w-2xl mx-auto px-4 py-10">
        <div class="mb-8">
          <h1 class="text-2xl font-bold text-slate-900">Form Pengajuan Email Kampus</h1>
          <p class="text-slate-500 mt-1">Isi data dengan benar dan unggah foto KTM Anda untuk verifikasi.</p>
        </div>

        <!-- Success State -->
        <%= if @submitted do %>
          <div class="bg-green-50 border border-green-200 rounded-2xl p-8 text-center shadow-lg">
            <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
              </svg>
            </div>
            <h2 class="text-xl font-bold text-green-800 mb-2">Pengajuan Terkirim!</h2>
            <p class="text-green-700 mb-6">Admin UPA TIK akan memproses pengajuan Anda dalam 1–3 hari kerja.</p>
            <div class="flex gap-3 justify-center">
              <a href="/portal/status"
                class="px-5 py-2.5 bg-green-600 text-white rounded-lg font-medium hover:bg-green-700 transition-colors shadow-md">
                Lihat Status
              </a>
              <button phx-click="reset"
                class="px-5 py-2.5 bg-white border border-green-300 text-green-700 rounded-lg font-medium hover:bg-green-50 transition-colors">
                Ajukan Lagi
              </button>
            </div>
          </div>
        <% else %>
          <div class="bg-white rounded-2xl shadow-xl border border-slate-200 overflow-hidden">
            <div class="bg-blue-600 px-6 py-4">
              <h2 class="text-white font-semibold">Data Pengajuan</h2>
              <p class="text-blue-100 text-xs mt-0.5">Semua kolom wajib diisi</p>
            </div>

            <form id="request-form" phx-submit="submit" phx-change="update_field" class="p-6 space-y-5">
              <!-- Jenis Pengajuan -->
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Jenis Pengajuan</label>
                <div class="grid grid-cols-2 gap-3">
                  <label class={[
                    "flex items-center gap-2 p-3 border-2 rounded-xl cursor-pointer transition-all",
                    if(@request_type == "aktivasi", do: "border-blue-500 bg-blue-50", else: "border-slate-100 hover:border-blue-300")
                  ]}>
                    <input type="radio" name="request_type" value="aktivasi"
                      checked={@request_type == "aktivasi"}
                      phx-click="set_type" phx-value-type="aktivasi"
                      class="accent-blue-600"/>
                    <div>
                      <p class="font-medium text-sm text-slate-800">Aktivasi</p>
                      <p class="text-xs text-slate-500 font-normal">Akun baru</p>
                    </div>
                  </label>
                  <label class={[
                    "flex items-center gap-2 p-3 border-2 rounded-xl cursor-pointer transition-all",
                    if(@request_type == "reset", do: "border-blue-500 bg-blue-50", else: "border-slate-100 hover:border-blue-300")
                  ]}>
                    <input type="radio" name="request_type" value="reset"
                      checked={@request_type == "reset"}
                      phx-click="set_type" phx-value-type="reset"
                      class="accent-blue-600"/>
                    <div>
                      <p class="font-medium text-sm text-slate-800">Reset Password</p>
                      <p class="text-xs text-slate-500 font-normal">Lupa password</p>
                    </div>
                  </label>
                </div>
              </div>

              <!-- NIM -->
              <div>
                <label for="nim" class="block text-sm font-semibold text-slate-700 mb-1">
                  NIM (Nomor Induk Mahasiswa)
                </label>
                <input
                  id="nim"
                  type="text"
                  name="nim"
                  value={@nim}
                  placeholder="Contoh: 2021001234"
                  phx-debounce="300"
                  class="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all placeholder:text-slate-400"
                  style="color: #000000 !important; background-color: #ffffff !important; -webkit-text-fill-color: #000000 !important; font-weight: 600;"
                  required
                />
                <%= if @errors[:nim] do %>
                  <p class="mt-1 text-xs text-red-600"><%= hd(@errors[:nim]) %></p>
                <% end %>
              </div>

              <!-- Nama Lengkap -->
              <div>
                <label for="full_name" class="block text-sm font-semibold text-slate-700 mb-1">
                  Nama Lengkap
                </label>
                <input
                  id="full_name"
                  type="text"
                  name="full_name"
                  value={@full_name}
                  placeholder="Sesuai KTM"
                  phx-debounce="300"
                  class="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all placeholder:text-slate-400"
                  style="color: #000000 !important; background-color: #ffffff !important; -webkit-text-fill-color: #000000 !important; font-weight: 600;"
                  required
                />
                <%= if @errors[:full_name] do %>
                  <p class="mt-1 text-xs text-red-600"><%= hd(@errors[:full_name]) %></p>
                <% end %>
              </div>

              <!-- Email -->
              <div>
                <label for="email_requested" class="block text-sm font-semibold text-slate-700 mb-1">
                  Email Kampus yang Diminta
                </label>
                <input
                  id="email_requested"
                  type="email"
                  name="email_requested"
                  value={@email_requested}
                  placeholder="nim@mahasiswa.kampus.ac.id"
                  phx-debounce="300"
                  class="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all placeholder:text-slate-400"
                  style="color: #000000 !important; background-color: #ffffff !important; -webkit-text-fill-color: #000000 !important; font-weight: 600;"
                  required
                />
                <%= if @errors[:email_requested] do %>
                  <p class="mt-1 text-xs text-red-600"><%= hd(@errors[:email_requested]) %></p>
                <% end %>
              </div>

              <!-- Upload KTM -->
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">
                  Foto KTM (Kartu Tanda Mahasiswa)
                </label>
                <div class="border-2 border-dashed rounded-xl p-5 text-center transition-colors border-slate-300 hover:border-blue-400 bg-slate-50/50"
                  phx-drop-target={@uploads.ktm_photo.ref}>

                  <%= for entry <- @uploads.ktm_photo.entries do %>
                    <div class="flex flex-col items-center p-3 bg-white rounded-lg border border-slate-200">
                      <.live_img_preview entry={entry} class="w-32 h-20 object-cover rounded-lg shadow-sm mb-3" />
                      <div class="w-full px-2">
                        <div class="flex items-center justify-between mb-1">
                          <p class="text-xs font-medium text-slate-700 truncate max-w-[150px]"><%= entry.client_name %></p>
                          <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref}
                            class="text-red-500 hover:text-red-700 p-1">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                            </svg>
                          </button>
                        </div>
                        <div class="w-full bg-slate-100 rounded-full h-1">
                          <div class="bg-blue-600 h-1 rounded-full transition-all" style={"width: #{entry.progress}%"}></div>
                        </div>
                      </div>
                    </div>
                    <%= for err <- upload_errors(@uploads.ktm_photo, entry) do %>
                      <p class="text-red-500 text-xs font-semibold mt-2"><%= upload_error_to_string(err) %></p>
                    <% end %>
                  <% end %>

                  <!-- Always keep input in DOM for upload continuity -->
                  <.live_file_input upload={@uploads.ktm_photo} class="sr-only"/>

                  <%= if Enum.empty?(@uploads.ktm_photo.entries) do %>
                    <label class="cursor-pointer block" for={@uploads.ktm_photo.ref}>
                      <svg class="w-10 h-10 text-slate-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                      </svg>
                      <p class="text-sm text-slate-700 font-bold">Pilih atau Seret Foto KTM</p>
                      <p class="text-xs text-slate-500 mt-1">Maks 5MB (JPG, PNG, WEBP)</p>
                    </label>
                  <% end %>
                </div>
              </div>

              <!-- Info Box -->
              <div class="bg-amber-50 border border-amber-200 rounded-xl p-4">
                <p class="text-xs text-amber-800 leading-relaxed font-medium">
                  <strong>⚠️ Perhatian:</strong> Pastikan foto KTM jelas dan dapat dibaca. Pengajuan dengan foto tidak jelas akan ditolak.
                </p>
              </div>

              <!-- Submit -->
              <button type="submit"
                disabled={not Enum.empty?(@uploads.ktm_photo.entries) and not Enum.all?(@uploads.ktm_photo.entries, &(&1.done?))}
                class="w-full py-3.5 bg-blue-600 hover:bg-blue-700 disabled:bg-slate-400 text-white font-bold rounded-xl shadow-lg transition-all duration-200 hover:-translate-y-0.5 shadow-blue-200 active:scale-[0.98]">
                <%= if not Enum.empty?(@uploads.ktm_photo.entries) and not Enum.all?(@uploads.ktm_photo.entries, &(&1.done?)) do %>
                  Mengunggah Foto (<%= hd(@uploads.ktm_photo.entries).progress %>%)
                <% else %>
                  Kirim Pengajuan Sekarang
                <% end %>
              </button>
            </form>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp upload_error_to_string(:too_large), do: "File terlalu besar (maks. 5MB)"
  defp upload_error_to_string(:too_many_files), do: "Hanya boleh 1 file"
  defp upload_error_to_string(:not_accepted), do: "Format tidak didukung (JPG/PNG/WEBP)"
end
