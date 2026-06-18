defmodule UpaTikPortal.Repo.Migrations.AddCategoryToKeluhans do
  use Ecto.Migration

  def change do
    alter table(:keluhans) do
      add :category, :string, default: "lainnya", null: false
    end
  end
end
