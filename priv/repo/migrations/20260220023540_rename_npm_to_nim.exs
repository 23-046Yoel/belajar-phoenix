defmodule UpaTikPortal.Repo.Migrations.RenameNpmToNim do
  use Ecto.Migration

  def change do
    rename table(:email_requests), :npm, to: :nim
  end
end
