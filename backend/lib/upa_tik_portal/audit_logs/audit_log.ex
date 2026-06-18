defmodule UpaTikPortal.AuditLogs.AuditLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "audit_logs" do
    field :action, :string
    field :details, :string
    field :target_type, :string
    field :target_id, :binary_id

    belongs_to :actor, UpaTikPortal.Accounts.User, foreign_key: :actor_id

    timestamps(type: :utc_datetime)
  end

  def changeset(audit_log, attrs) do
    audit_log
    |> cast(attrs, [:action, :details, :target_type, :target_id, :actor_id])
    |> validate_required([:action, :actor_id])
  end
end
