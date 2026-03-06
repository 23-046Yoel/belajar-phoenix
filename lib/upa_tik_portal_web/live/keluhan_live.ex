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

  defp status_badge("baru"), do: {"bg-blue-100 text-blue-700", "🆕 Baru"}
  defp status_badge("diproses"), do: {"bg-amber-100 text-amber-700", "⏳ Diproses"}
  defp status_badge("selesai"), do: {"bg-green-100 text-green-700", "✅ Selesai"}
  defp status_badge(_), do: {"bg-slate-100 text-slate-700", "Unknown"}

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50">
      <%!-- Navbar --%>
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
            <a href="/portal/ajukan" class="text-sm text-slate-500 hover:text-blue-600 transition-colors">Pengajuan</a>
            <a href="/portal/status" class="text-sm text-slate-500 hover:text-blue-600 transition-colors">Status</a>
            <a href="/portal/keluhan" class="text-sm text-blue-600 font-semibold">Lapor Masalah</a>
            <a href="/auth/logout" class="text-sm text-slate-500 hover:text-red-600 transition-colors">Logout</a>
          </div>
        </div>
      </nav>

      <div class="max-w-3xl mx-auto px-4 py-10 space-y-8">
        <%!-- Header --%>
        <div>
          <h1 class="text-2xl font-bold text-slate-900">Pengajuan Email Kampus Bermasalah</h1>
          <p class="text-slate-500 mt-1">Sampaikan masalah atau kendala yang Anda alami kepada tim UPA TIK.</p>
        </div>

        <%!-- Form Keluhan --%>
        <%= if @submitted do %>
          <div class="bg-green-50 border border-green-200 rounded-2xl p-8 text-center">
            <div class="w-14 h-14 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg class="w-7 h-7 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
              </svg>
            </div>
            <h2 class="text-lg font-bold text-green-800 mb-1">Keluhan Terkirim!</h2>
            <p class="text-green-600 text-sm mb-5">Tim UPA TIK akan menindaklanjuti keluhan Anda segera.</p>
            <button phx-click="new_keluhan"
              class="px-5 py-2 bg-green-600 text-white rounded-xl text-sm font-medium hover:bg-green-700 transition-colors">
              Kirim Keluhan Lain
            </button>
          </div>
        <% else %>
          <div class="bg-white rounded-2xl shadow-sm border border-slate-200">
            <div class="bg-blue-600 px-6 py-4 rounded-t-2xl">
              <h2 class="text-white font-semibold uppercase">FORM PENGAJUAN EMAIL KAMPUS BERMASALAH</h2>
              <p class="text-blue-100 text-xs mt-0.5">Berikan detail masalah Anda dengan jelas</p>
            </div>
            <form phx-submit="submit" phx-change="update_field" class="p-6 space-y-5">
              <%!-- Subject --%>
              <div>
                <label for="subject" class="block text-sm font-semibold text-slate-700 mb-1">
                  Judul Keluhan
                </label>
                <input
                  id="subject"
                  type="text"
                  name="subject"
                  value={@subject}
                  placeholder="Contoh: Email tidak bisa login / Password tidak valid"
                  phx-debounce="300"
                  class="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all placeholder:text-slate-400 text-slate-900"
                  required
                />
                <%= if @errors[:subject] do %>
                  <p class="mt-1 text-xs text-red-600"><%= hd(@errors[:subject]) %></p>
                <% end %>
              </div>

              <%!-- Description --%>
              <div>
                <label for="description" class="block text-sm font-semibold text-slate-700 mb-1">
                  Isi Keluhan
                </label>
                <textarea
                  id="description"
                  name="description"
                  rows="5"
                  placeholder="Jelaskan keluhan Anda secara detail..."
                  phx-debounce="300"
                  class="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all placeholder:text-slate-400 text-slate-900 resize-none"
                  required
                ><%= @description %></textarea>
                <%= if @errors[:description] do %>
                  <p class="mt-1 text-xs text-red-600"><%= hd(@errors[:description]) %></p>
                <% end %>
              </div>

              <button type="submit"
                class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl shadow-md transition-all duration-200">
                Kirim Pengajuan Bermasalah
              </button>
            </form>
          </div>
        <% end %>

        <%!-- Riwayat Keluhan --%>
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200">
          <div class="px-6 py-4 border-b border-slate-100">
            <h2 class="font-semibold text-slate-800">Riwayat Pengajuan Bermasalah Saya</h2>
          </div>
          <%= if Enum.empty?(@keluhans) do %>
            <div class="px-6 py-10 text-center text-slate-400">
              <svg class="w-10 h-10 mx-auto mb-2 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
              </svg>
              <p class="text-sm">Anda belum pernah mengirim keluhan.</p>
            </div>
          <% else %>
            <ul class="divide-y divide-slate-100">
              <%= for keluhan <- @keluhans do %>
                <% {badge_class, badge_text} = status_badge(keluhan.status) %>
                <li class="px-6 py-4">
                  <div class="flex items-start justify-between gap-3">
                    <div class="flex-1 min-w-0">
                      <p class="text-sm font-semibold text-slate-800 truncate"><%= keluhan.subject %></p>
                      <p class="text-xs text-slate-500 mt-0.5 line-clamp-2"><%= keluhan.description %></p>
                      <%= if keluhan.admin_notes do %>
                        <p class="text-xs text-indigo-600 mt-1 italic">📝 Catatan admin: <%= keluhan.admin_notes %></p>
                      <% end %>
                    </div>
                    <span class={"text-xs font-semibold px-2.5 py-1 rounded-full shrink-0 #{badge_class}"}>
                      <%= badge_text %>
                    </span>
                  </div>
                  <p class="text-xs text-slate-400 mt-1.5">
                    <%= Calendar.strftime(keluhan.inserted_at, "%d %b %Y, %H:%M") %>
                  </p>
                </li>
              <% end %>
            </ul>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
