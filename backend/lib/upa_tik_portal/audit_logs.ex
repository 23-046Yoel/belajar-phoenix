defmodule UpaTikPortal.AuditLogs do
  @moduledoc """
  Context untuk pencatatan log audit aktivitas admin.
  """
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.AuditLogs.AuditLog

  @doc "Daftar semua log audit, terurut terbaru dahulu"
  def list_audit_logs do
    AuditLog
    |> order_by(desc: :inserted_at)
    |> preload(:actor)
    |> Repo.all()
  end

  @doc "Mencatat log audit baru"
  def log_action(actor_id, action, target_type \\ nil, target_id \\ nil, details \\ nil) do
    %AuditLog{}
    |> AuditLog.changeset(%{
      actor_id: actor_id,
      action: action,
      target_type: target_type,
      target_id: target_id,
      details: details
    })
    |> Repo.insert()
  end
end
