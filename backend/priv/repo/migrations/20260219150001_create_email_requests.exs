defmodule UpaTikPortal.Repo.Migrations.CreateEmailRequests do
  use Ecto.Migration

  def change do
    create table(:email_requests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :npm, :string, null: false
      add :full_name, :string, null: false
      add :email_requested, :string, null: false
      add :request_type, :string, default: "aktivasi", null: false
      add :ktm_photo_url, :string
      add :status, :string, default: "pending", null: false
      add :otp_code, :string
      add :otp_sent_at, :utc_datetime
      add :admin_notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:email_requests, [:user_id])
    create index(:email_requests, [:status])
  end
end
