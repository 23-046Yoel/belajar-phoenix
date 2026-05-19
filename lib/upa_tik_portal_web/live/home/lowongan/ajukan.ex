defmodule UpaTikPortalWeb.Home.Lowongan.Ajukan do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.InternshipParticipation
  alias UpaTikPortal.Recruitment.InternshipOpeningService

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  @max_file_size 5_000_000

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    changeset = InternshipParticipationService.change_internship_participation(%InternshipParticipation{})
    opening = InternshipOpeningService.get_internship_opening!(id)
    user = socket.assigns.current_user

    socket =
      socket
      |> allow_upload(:cv,
        accept: ~w(.pdf),
        max_entries: 1,
        max_file_size: @max_file_size
      )
      |> allow_upload(:surat_pengantar,
        accept: ~w(.pdf),
        max_entries: 1,
        max_file_size: @max_file_size
      )
      |> allow_upload(:transkrip,
        accept: ~w(.pdf),
        max_entries: 1,
        max_file_size: @max_file_size
      )
      |> allow_upload(:portfolio_file,
        accept: ~w(.pdf .ppt .pptx),
        max_entries: 1,
        max_file_size: @max_file_size
      )

    {:ok,
     socket
     |> assign(:page_title, opening.title)
     |> assign(:opening, opening)
     |> assign(:user, user)
     |> assign(:portfolio_mode, "link")
     |> assign(:form, to_form(changeset))
     |> assign(:has_applied, false)}
  end

  @impl true
  def handle_event("validate", %{"internship_participation" => params}, socket) do
    changeset =
      %InternshipParticipation{}
      |> InternshipParticipationService.change_internship_participation(params)
      |> Map.put(:action, :validate)
    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("change_portfolio_mode", %{"mode" => mode}, socket) do
    {:noreply,
    assign(socket, :portfolio_mode, mode)}
  end

  @impl true
  def handle_event("save_application", %{"internship_participation" => params}, socket) do
    user_id = socket.assigns.current_user.id
    opening_id = socket.assigns.opening.id
    final_params = params
      |> Map.put("user_id", user_id)
      |> Map.put("opening_id", opening_id)
    case InternshipParticipationService.create_internship_participation(final_params) do
      {:ok, _participation} ->
        {:noreply,
        socket
        |> put_flash(:info, "Lamaran berhasil dikirim dan kuota telah dikurangi!")
        |> push_navigate(to: ~p"/portal/lowongan")}

      {:error, :quota_full} ->
        {:noreply,
        socket
        |> put_flash(:error, "Maaf, kuota untuk lowongan ini sudah penuh!")
        |> push_navigate(to: ~p"/portal/lowongan")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(%{changeset | action: :insert}))}
    end
  end
end
