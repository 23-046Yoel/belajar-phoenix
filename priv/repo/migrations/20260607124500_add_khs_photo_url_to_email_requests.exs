defmodule UpaTikPortal.Repo.Migrations.AddKhsPhotoUrlToEmailRequests do
  use Ecto.Migration

  def change do
    alter table(:email_requests) do
      add :khs_photo_url, :string
    end
  end
end
