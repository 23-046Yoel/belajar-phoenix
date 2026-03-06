defmodule UpaTikPortal.Repo.Migrations.CreateKeluhans do
  use Ecto.Migration

  def change do
    create table(:keluhans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :subject, :string, null: false
      add :description, :text, null: false
      add :status, :string, default: "baru", null: false
      add :admin_notes, :text
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:keluhans, [:user_id])
    create index(:keluhans, [:status])
  end
end
