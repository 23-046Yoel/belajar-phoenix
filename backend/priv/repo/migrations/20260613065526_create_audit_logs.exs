defmodule UpaTikPortal.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :action, :string, null: false
      add :details, :text
      add :actor_id, references(:users, on_delete: :nilify_all, type: :binary_id)
      add :target_type, :string
      add :target_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:audit_logs, [:actor_id])
    create index(:audit_logs, [:inserted_at])
  end
end
