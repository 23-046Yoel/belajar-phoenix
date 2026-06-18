defmodule UpaTikPortal.Repo.Migrations.CreateInternshipOpenings do
  use Ecto.Migration

  def change do
    create table(:internship_openings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :description, :text
      add :department, :string
      add :quota, :integer
      add :is_active, :boolean, default: true
      add :closing_date, :date

      timestamps(type: :utc_datetime)
    end
  end
end