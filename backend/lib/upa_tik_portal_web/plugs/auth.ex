defmodule UpaTikPortalWeb.Plugs.Auth do
  @moduledoc """
  Plugs untuk autentikasi dan otorisasi berbasis session.
  """
  import Plug.Conn
  import Phoenix.Controller
  alias UpaTikPortal.Accounts

  @doc "Muat user dari session ke assigns"
  def load_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user_name = get_session(conn, :user_name)
    user_email = get_session(conn, :user_email)
    user_role = get_session(conn, :user_role)

    if user_id do
      if user_name && user_email && user_role do
        user = %UpaTikPortal.Accounts.User{
          id: user_id,
          name: user_name,
          email: user_email,
          role: user_role
        }
        assign(conn, :current_user, user)
      else
        # Fallback to DB query if session details are incomplete
        case Accounts.get_user(user_id) do
          nil -> assign(conn, :current_user, nil)
          user -> assign(conn, :current_user, user)
        end
      end
    else
      assign(conn, :current_user, nil)
    end
  end

  @doc "Wajib login — redirect ke / jika belum login"
  def require_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Silakan login terlebih dahulu.")
      |> redirect(to: "/")
      |> halt()
    end
  end

  @doc "Wajib admin — 403 jika bukan admin"
  def require_admin(conn, _opts) do
    case conn.assigns[:current_user] do
      %{role: "admin"} ->
        conn

      _ ->
        conn
        |> put_status(:forbidden)
        |> put_flash(:error, "Akses ditolak. Hanya admin yang dapat mengakses halaman ini.")
        |> redirect(to: "/portal/ajukan")
        |> halt()
    end
  end
end
