defmodule UpaTikPortal.Recruitment.InternshipOpening do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "internship_openings" do
    field :title, :string
    field :description, :string
    field :department, :string
    field :quota, :integer
    field :is_active, :boolean, default: true
    field :closing_date, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(internship_opening, attrs) do
    internship_opening
    |> cast(attrs, [:title, :description, :department, :quota, :is_active, :closing_date])
    |> validate_required([:title, :description, :department, :quota, :closing_date])
  end
end
