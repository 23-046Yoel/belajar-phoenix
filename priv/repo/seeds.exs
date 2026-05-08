# Script untuk mengisi data awal database.
# Jalankan dengan: mix run priv/repo/seeds.exs

alias UpaTikPortal.Repo
alias UpaTikPortal.Accounts.User

# Buat admin pertama jika belum ada
admin_email = System.get_env("ADMIN_EMAIL") || "admin@upa-tik.ac.id"

case Repo.get_by(User, email: admin_email) do
  nil ->
    %User{}
    |> User.changeset(%{
      name: "Administrator UPA TIK",
      email: admin_email,
      role: "admin"
    })
    |> Repo.insert!()

    IO.puts("✅ Admin user created: #{admin_email}")

  _existing ->
    IO.puts("ℹ️  Admin user already exists: #{admin_email}")
end

