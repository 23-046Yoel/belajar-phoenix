# Script untuk mengisi data awal database.
# Jalankan dengan: mix run priv/repo/seeds.exs

alias UpaTikPortal.Repo
alias UpaTikPortal.Accounts.User
alias UpaTikPortal.Recruitment.InternshipOpening

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

    openings = [
      %{
        title: "Fullstack Web Developer",
        description: "Membangun sistem informasi internal menggunakan Laravel dan Livewire.",
        department: "Pusat Data dan Informasi",
        quota: 5,
        is_active: true,
        closing_date: ~D[2026-06-30]
      },
      %{
        title: "Mobile App Developer (Flutter)",
        description: "Mengembangkan aplikasi presensi mahasiswa berbasis Android dan iOS.",
        department: "Divisi Mobile Learning",
        quota: 3,
        is_active: true,
        closing_date: ~D[2026-07-15]
      },
      %{
        title: "Data Scientist Intern",
        description: "Melakukan analisis data akademik dan pembuatan model prediksi kelulusan.",
        department: "Laboratorium Sains Data",
        quota: 2,
        is_active: true,
        closing_date: ~D[2026-06-20]
      },
      %{
        title: "Network & Security Support",
        description: "Membantu maintenance jaringan fiber optic dan pengamanan server kampus.",
        department: "Infrastruktur Jaringan",
        quota: 4,
        is_active: true,
        closing_date: ~D[2026-08-01]
      },
      %{
        title: "UI/UX Designer",
        description: "Merancang antarmuka untuk portal layanan mahasiswa baru.",
        department: "Creative Media Center",
        quota: 2,
        is_active: true,
        closing_date: ~D[2026-06-25]
      }
    ]

    Enum.each(openings, fn data ->
      case Repo.get_by(InternshipOpening, title: data.title) do
        nil ->
          # Jika data belum ada, insert baru
          Repo.insert!(struct(InternshipOpening, data))

        _ ->
          # Jika sudah ada, lewati (agar tidak double saat seed dijalankan ulang)
          IO.puts("Opening '#{data.title}' sudah ada, melewati...")
      end
    end)

    IO.puts("Seeding 5 Internship Openings selesai!")
end
