# lib/upa_tik_portal_web/live/admin/lowongan_live/new.ex
defmodule UpaTikPortalWeb.Admin.LowonganLive.New do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment
  alias UpaTikPortal.Recruitment.InternshipOpening

  @impl true
  def mount(_params, _session, socket) do
    # Siapkan changeset kosong
    changeset = Recruitment.change_internship_opening(%InternshipOpening{})

    {:ok,
     socket
     |> assign(:page_title, "Tambah Lowongan Baru")
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"internship_opening" => params}, socket) do
    changeset =
      %InternshipOpening{}
      |> Recruitment.change_internship_opening(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"internship_opening" => params}, socket) do
    case Recruitment.create_internship_opening(params) do
      {:ok, _opening} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lowongan berhasil diterbitkan!")
         |> push_navigate(to: ~p"/admin/lowongan")} # Kembali ke daftar

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
