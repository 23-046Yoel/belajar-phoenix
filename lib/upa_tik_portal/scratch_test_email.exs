# Script untuk mengetes pengiriman email secara manual
# Jalankan dengan: mix run lib/upa_tik_portal/scratch/test_email.exs

alias UpaTikPortal.Mailer
alias Swoosh.Email

# Ambil data dari ENV
smtp_user = System.get_env("SMTP_USER")
smtp_pass = System.get_env("SMTP_PASSWORD")

IO.puts("--- MEMULAI TEST EMAIL ---")
IO.puts("Menggunakan User: #{smtp_user}")
IO.puts("Menggunakan Pass: #{String.slice(smtp_pass, 0, 4)}****")

email =
  Email.new()
  # Kita tes kirim ke email kamu sendiri
  |> Email.to("yoelflemming8@gmail.com")
  |> Email.from({"TEST AGENT", smtp_user})
  |> Email.subject("TEST EMAIL DARI AGENT")
  |> Email.text_body("Halo, ini adalah email test untuk mengecek koneksi SMTP Gmail.")

case Mailer.deliver(email) do
  {:ok, _} ->
    IO.puts("\n✅ BERHASIL! Email terkirim ke Gmail.")
    IO.puts("Cek kotak masuk atau folder SPAM.")

  {:error, reason} ->
    IO.puts("\n❌ GAGAL MENGIRIM!")
    IO.inspect(reason, label: "Detail Error")
end
