defmodule UpaTikPortalWeb.LoginLive do
  use UpaTikPortalWeb, :live_view

  def mount(_params, session, socket) do
    current_user = get_user_from_session(session)
    IO.inspect(current_user, label: "current_user")
    if current_user do
      {:ok, push_navigate(socket, to: redirect_path(current_user))}
    else
      {:ok, assign(socket, page_title: "Login – UPA TIK Portal", current_user: nil)}
    end
  end

  defp get_user_from_session(%{"user_id" => id}) when not is_nil(id) do
    UpaTikPortal.Accounts.get_user(id)
  end

  defp get_user_from_session(_), do: nil

  defp redirect_path(%{role: "admin"}), do: ~p"/admin"
  defp redirect_path(_), do: ~p"/portal/home"

  def render(assigns) do
    ~H"""
    <.flash kind={:info} title="Berhasil!" flash={@flash} />
    <.flash kind={:error} title="Error!" flash={@flash} />

    <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-950 via-blue-900 to-indigo-900 px-4">
      <!-- Decorative blobs -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <div class="absolute -top-40 -right-40 w-96 h-96 bg-blue-500 opacity-20 rounded-full blur-3xl"></div>
        <div class="absolute -bottom-40 -left-40 w-96 h-96 bg-indigo-500 opacity-20 rounded-full blur-3xl"></div>
      </div>

      <div class="relative w-full max-w-md">
        <!-- Logo & Header -->
        <div class="text-center mb-8">
          <div class="inline-flex items-center justify-center w-20 h-20 rounded-2xl bg-white/10 backdrop-blur-sm border border-white/20 mb-4 shadow-2xl">
            <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M12 14l9-5-9-5-9 5 9 5z"/>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z"/>
            </svg>
          </div>
          <h1 class="text-3xl font-bold text-white tracking-tight">UPA TIK Portal</h1>
          <p class="text-blue-200 mt-1 text-sm">Unit Pelaksana Akademik Teknologi Informasi &amp; Komunikasi</p>
        </div>

        <!-- Card -->
        <div class="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl shadow-2xl p-8">
          <h2 class="text-xl font-semibold text-white text-center mb-2">Selamat Datang</h2>
          <p class="text-blue-200 text-sm text-center mb-8">
            Masuk untuk mengajukan aktivasi atau reset email kampus Anda
          </p>

          <!-- Google Login Button -->
          <a
            href="/auth/google"
            class="group flex items-center justify-center gap-3 w-full py-3.5 px-6 bg-white hover:bg-blue-50 text-gray-800 font-semibold rounded-xl shadow-lg transition-all duration-200 hover:shadow-xl hover:-translate-y-0.5"
          >
            <!-- Google SVG Icon -->
            <svg class="w-5 h-5" viewBox="0 0 24 24">
              <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
              <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
              <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            Masuk dengan Google
          </a>

          <div class="mt-6 pt-6 border-t border-white/10">
            <p class="text-xs text-blue-300 text-center leading-relaxed">
              Gunakan akun Google pribadi Anda. Pengajuan akan diproses oleh admin UPA TIK setelah verifikasi KTM.
            </p>
          </div>
        </div>

        <!-- Footer -->
        <p class="text-center text-blue-400 text-xs mt-6">
          © 2026 UPA TIK – Semua hak dilindungi
        </p>
      </div>
    </div>
    """
  end
end
