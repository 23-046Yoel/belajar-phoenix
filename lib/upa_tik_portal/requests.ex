defmodule UpaTikPortal.Requests do
  @moduledoc """
  Context untuk manajemen pengajuan aktivasi/reset email kampus.
  """
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Requests.EmailRequest
  alias UpaTikPortal.Mailer
  alias UpaTikPortal.Emails

  @doc "Daftar semua pengajuan, diurutkan terbaru dulu"
  def list_requests do
    Repo.all(from r in EmailRequest, order_by: [desc: r.inserted_at], preload: [:user])
  end

  @doc "Daftar pengajuan milik user tertentu"
  def list_requests_by_user(user_id) do
    Repo.all(
      from r in EmailRequest,
        where: r.user_id == ^user_id,
        order_by: [desc: r.inserted_at]
    )
  end

  @doc "Dapatkan satu pengajuan (404 jika tidak ada)"
  def get_request!(id), do: Repo.get!(EmailRequest, id) |> Repo.preload(:user)

  @doc "Buat pengajuan baru"
  def create_request(user_id, attrs) do
    %EmailRequest{user_id: user_id}
    |> EmailRequest.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Update status pengajuan (Disetujui / Ditolak)"
  def update_status(%EmailRequest{} = request, status, notes \\ nil) do
    request
    |> EmailRequest.status_changeset(%{status: status, admin_notes: notes})
    |> Repo.update()
  end

  @doc "Simpan catatan admin saja"
  def update_admin_notes(%EmailRequest{} = request, notes) do
    request
    |> EmailRequest.notes_changeset(%{admin_notes: notes})
    |> Repo.update()
  end

  @doc "Hapus pengajuan"
  def delete_request(%EmailRequest{} = request) do
    Repo.delete(request)
  end

  @doc """
  Generate OTP 6-digit (atau gunakan custom), simpan ke DB, dan kirim email ke mahasiswa.
  """
  def send_otp(%EmailRequest{} = request, custom_otp \\ nil) do
    otp = custom_otp || :crypto.strong_rand_bytes(3) |> Base.encode16() |> String.slice(0, 6)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    with {:ok, updated_request} <-
           request
           |> EmailRequest.otp_changeset(%{otp_code: otp, otp_sent_at: now})
           |> Repo.update(),
         {:ok, _email} <- Emails.otp_email(updated_request) |> Mailer.deliver() do
      {:ok, updated_request}
    end
  end

  @doc "Statistik: jumlah per status"
  def stats do
    Repo.all(
      from r in EmailRequest,
        group_by: r.status,
        select: {r.status, count(r.id)}
    )
    |> Enum.into(%{})
  end
end
