# lib/upa_tik_portal_web/user_auth.ex
defmodule UpaTikPortalWeb.UserAuth do
  import Phoenix.Component
  import Phoenix.LiveView
  alias UpaTikPortal.Accounts

  def on_mount(:mount_current_user, _params, session, socket) do
    case Accounts.get_user_from_session(session) do
      nil ->
        # Jika tidak ada session, lempar ke login
        {:halt, redirect(socket, to: "/auth/google")}

      user ->
        {:cont, assign(socket, :current_user, user)}
    end
  end
end
