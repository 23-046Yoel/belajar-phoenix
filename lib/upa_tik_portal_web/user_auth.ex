# lib/upa_tik_portal_web/user_auth.ex
defmodule UpaTikPortalWeb.UserAuth do
  import Phoenix.Component
  import Phoenix.LiveView
  alias UpaTikPortal.Accounts

  def on_mount(:mount_current_user, _params, session, socket) do
    case session["user_id"] do
      nil ->
        # Jika tidak ada session, lempar ke login
        {:halt, redirect(socket, to: "/auth/google")}

      user_id ->
        user = Accounts.get_user(user_id)
        {:cont, assign(socket, :current_user, user)}
    end
  end
end
