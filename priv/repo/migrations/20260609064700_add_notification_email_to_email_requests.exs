defmodule UpaTikPortal.Repo.Migrations.AddNotificationEmailToEmailRequests do
  use Ecto.Migration

  def change do
    alter table(:email_requests) do
      add :notification_email, :string
    end
  end
end
