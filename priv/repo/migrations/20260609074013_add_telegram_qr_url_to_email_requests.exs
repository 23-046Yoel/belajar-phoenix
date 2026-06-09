defmodule UpaTikPortal.Repo.Migrations.AddTelegramQrUrlToEmailRequests do
  use Ecto.Migration

  def change do
    alter table(:email_requests) do
      add :telegram_qr_url, :string
    end
  end
end
