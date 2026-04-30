defmodule UpaTikPortalWeb.Admin.LowonganLive.FormComponent do
  use UpaTikPortalWeb, :live_component
  alias UpaTikPortal.Recruitment

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="lowongan-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Judul Lowongan" placeholder="Contoh: Backend Developer" />
        <.input field={@form[:department]} type="text" label="Departemen" />
        <.input field={@form[:description]} type="textarea" label="Deskripsi" />

        <div class="grid grid-cols-2 gap-4">
          <.input field={@form[:quota]} type="number" label="Kuota" />
          <.input field={@form[:closing_date]} type="date" label="Tanggal Penutupan" />
        </div>

        <.input field={@form[:is_active]} type="checkbox" label="Aktifkan Lowongan" />

        <:actions>
          <.button phx-disable-with="Menyimpan...">Simpan Lowongan</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{opening: opening} = assigns, socket) do
    changeset = Recruitment.change_internship_opening(opening)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"internship_opening" => params}, socket) do
    changeset =
      socket.assigns.opening
      |> Recruitment.change_internship_opening(params)
      |> Map.put(:action, :validate)

    {:ok, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"internship_opening" => params}, socket) do
    save_lowongan(socket, socket.assigns.action, params)
  end

  defp save_lowongan(socket, :new, params) do
    case Recruitment.create_internship_opening(params) do
      {:ok, opening} ->
        notify_parent({:saved, opening})

        {:noreply,
         socket
         |> put_flash(:info, "Lowongan berhasil dibuat")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
