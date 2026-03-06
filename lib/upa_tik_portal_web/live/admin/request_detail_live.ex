defmodule UpaTikPortalWeb.Admin.RequestDetailLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  def mount(%{"id" => id}, _session, socket) do
    request = Requests.get_request!(id)

    {:ok,
     assign(socket,
       page_title: "Detail Pengajuan – Admin UPA TIK",
       request: request,
       notes: request.admin_notes || "",
       manual_otp: "",
       sending_otp: false,
       otp_sent: false
     )}
  end

  def handle_event("approve", _params, socket) do
    case Requests.update_status(socket.assigns.request, "disetujui", socket.assigns.notes) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(request: updated)
         |> put_flash(:info, "✅ Pengajuan berhasil disetujui.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengupdate status.")}
    end
  end

  def handle_event("reject", _params, socket) do
    case Requests.update_status(socket.assigns.request, "ditolak", socket.assigns.notes) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(request: updated)
         |> put_flash(:info, "❌ Pengajuan ditolak.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengupdate status.")}
    end
  end

  def handle_event("update-field", %{"notes" => notes, "otp" => otp}, socket) do
    {:noreply, assign(socket, notes: notes, manual_otp: otp)}
  end

  def handle_event("update-field", %{"notes" => notes}, socket) do
    {:noreply, assign(socket, notes: notes)}
  end

  def handle_event("update-field", %{"otp" => otp}, socket) do
    {:noreply, assign(socket, manual_otp: otp)}
  end

  def handle_event("send-otp", _params, socket) do
    request = socket.assigns.request

    if request.status != "disetujui" do
      {:noreply, put_flash(socket, :error, "Setujui pengajuan terlebih dahulu sebelum mengirim OTP.")}
    else
      socket = assign(socket, sending_otp: true)
      otp_to_send = if socket.assigns.manual_otp != "", do: socket.assigns.manual_otp, else: nil

      case Requests.send_otp(request, otp_to_send) do
        {:ok, updated} ->
          {:noreply,
           socket
           |> assign(request: updated, sending_otp: false, otp_sent: true, manual_otp: "")
           |> put_flash(:info, "📧 Kode OTP berhasil dikirim ke #{request.email_requested}")}

        {:error, _} ->
          {:noreply,
           socket
           |> assign(sending_otp: false)
           |> put_flash(:error, "Gagal mengirim OTP. Coba lagi.")}
      end
    end
  end

  def handle_event("save-notes", _params, socket) do
    case Requests.update_admin_notes(socket.assigns.request, socket.assigns.notes) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(request: updated)
         |> put_flash(:info, "✅ Catatan berhasil disimpan.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal menyimpan catatan.")}
    end
  end

  def handle_event("delete", _params, socket) do
    case Requests.delete_request(socket.assigns.request) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pengajuan berhasil dihapus.")
         |> push_navigate(to: "/admin/pengajuan")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal menghapus.")}
    end
  end

  defp status_class("pending"), do: "bg-amber-100 text-amber-800"
  defp status_class("disetujui"), do: "bg-green-100 text-green-800"
  defp status_class("ditolak"), do: "bg-red-100 text-red-800"
  defp status_class(_), do: "bg-slate-100 text-slate-800"

  defp status_label("pending"), do: "⏳ Menunggu"
  defp status_label("disetujui"), do: "✅ Disetujui"
  defp status_label("ditolak"), do: "❌ Ditolak"
  defp status_label(s), do: s

  defp format_type("aktivasi"), do: "Aktivasi Akun"
  defp format_type("reset"), do: "Reset Password"
  defp format_type(t), do: t
end
