defmodule UpaTikPortalWeb.Home.Setting.Profile do
  use UpaTikPortalWeb, :live_view
  # alias UpaTikPortal.Recruitment.InternshipOpeningService
  alias UpaTikPortal.Accounts

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    # Inisialisasi form dengan data user
    # Jika menggunakan Ecto: changeset = User.changeset(user, %{})

    {:ok,
     socket
     |> assign(:page_title, "Profil Saya")
     |> assign(:user, user)
     |> assign(:form, to_form(%{"name" => user.name}))}
  end

  @impl true
  def handle_event("save_profile", %{"name" => new_name}, socket) do
    user = socket.assigns.current_user
    case Accounts.update_user(user, %{name: new_name}) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profil berhasil diperbarui.")
         |> assign(:user, updated_user)
         |> assign(:form, to_form(%{"name" => updated_user.name}))}
      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Profil gagal diperbarui.")
         |> assign(:form, to_form(%{"name" => user.name}))}
    end
  end
end
