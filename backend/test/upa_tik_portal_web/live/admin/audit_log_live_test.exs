defmodule UpaTikPortalWeb.Admin.AuditLogLiveTest do
  use UpaTikPortalWeb.ConnCase
  import Phoenix.LiveViewTest

  alias UpaTikPortal.Accounts
  alias UpaTikPortal.AuditLogs

  defp create_user(role) do
    {:ok, user} =
      UpaTikPortal.Repo.insert(%Accounts.User{
        name: "Test Aktor",
        email: "aktor_#{role}@example.com",
        role: role,
        google_uid: "uid_#{role}"
      })

    user
  end

  test "redirects to login when unauthenticated", %{conn: conn} do
    conn = get(conn, ~p"/admin/logs")
    assert redirected_to(conn) == ~p"/"
  end

  test "redirects to portal when authenticated as student", %{conn: conn} do
    student = create_user("mahasiswa")
    conn = conn |> init_test_session(user_id: student.id) |> get(~p"/admin/logs")
    assert redirected_to(conn, 403) == ~p"/portal/ajukan"
  end

  test "renders audit logs page when authenticated as admin", %{conn: conn} do
    admin = create_user("admin")
    conn = conn |> init_test_session(user_id: admin.id)

    {:ok, _view, html} = live(conn, ~p"/admin/logs")
    assert html =~ "Log Aktivitas"
    assert html =~ "Audit Trail"
  end

  test "displays recorded audit logs", %{conn: conn} do
    admin = create_user("admin")

    # Record an action
    {:ok, _log} =
      AuditLogs.log_action(
        admin.id,
        "approve_request",
        "email_request",
        admin.id,
        "Test setuju pengajuan"
      )

    conn = conn |> init_test_session(user_id: admin.id)
    {:ok, _view, html} = live(conn, ~p"/admin/logs")

    assert html =~ "Test Aktor"
    assert html =~ "Test setuju pengajuan"
  end
end
