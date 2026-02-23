defmodule UpaTikPortal.Repo do
  use Ecto.Repo,
    otp_app: :upa_tik_portal,
    adapter: Ecto.Adapters.Postgres
end
