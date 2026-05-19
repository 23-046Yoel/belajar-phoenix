defmodule UpaTikPortal.Repo.Migrations.CreateInternshipParticipations do
  use Ecto.Migration

  def change do
    create table(:internship_participations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :cv_url, :string
      add :portfolio_url, :string
      add :surat_pengantar_url, :string
      add :transkrip_nilai_url, :string
      add :university, :string
      add :major, :string
      add :status, :string, default: "applied", null: false
      add :start_date, :date
      add :end_date, :date

      # Relasi
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :opening_id, references(:internship_openings, on_delete: :nothing, type: :binary_id)
      add :mentor_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:internship_participations, [:user_id])
    create index(:internship_participations, [:opening_id])
    create index(:internship_participations, [:mentor_id])
  end
end
