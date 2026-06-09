defmodule UpaTikPortal.Requests.EmailRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "email_requests" do
    field :nim, :string
    field :full_name, :string
    field :email_requested, :string
    field :request_type, :string, default: "aktivasi"
    field :ktm_photo_url, :string
    field :khs_photo_url, :string
    field :notification_email, :string
    field :status, :string, default: "pending"
    field :otp_code, :string
    field :otp_sent_at, :utc_datetime
    field :admin_notes, :string
    field :telegram_qr_url, :string

    belongs_to :user, UpaTikPortal.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(email_request, attrs) do
    email_request
    |> cast(attrs, [
      :nim,
      :full_name,
      :email_requested,
      :request_type,
      :ktm_photo_url,
      :khs_photo_url,
      :notification_email,
      :user_id,
      :telegram_qr_url
    ])
    |> validate_required([:nim, :full_name, :email_requested, :request_type, :user_id, :notification_email])
    |> validate_format(:email_requested, ~r/@/, message: "harus berformat email")
    |> validate_format(:notification_email, ~r/@/, message: "harus berformat email")
    |> validate_inclusion(:request_type, ["aktivasi", "reset"])
  end

  def status_changeset(email_request, attrs) do
    email_request
    |> cast(attrs, [:status, :admin_notes, :telegram_qr_url])
    |> validate_required([:status])
    |> validate_inclusion(:status, ["pending", "disetujui", "ditolak"])
  end

  def notes_changeset(email_request, attrs) do
    email_request
    |> cast(attrs, [:admin_notes])
  end

  def otp_changeset(email_request, attrs) do
    email_request
    |> cast(attrs, [:otp_code, :otp_sent_at])
  end
end
