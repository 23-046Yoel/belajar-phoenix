defmodule UpaTikPortal.Recruitment.InternshipParticipation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "internship_participations" do
    field :cv_url, :string
    field :portfolio_url, :string
    field :surat_pengantar_url, :string
    field :transkrip_nilai_url, :string
    field :university, :string
    field :major, :string
    field :status, :string, default: "applied"
    field :start_date, :date
    field :end_date, :date

    belongs_to :users, UpaTikPortal.Accounts.User, foreign_key: :user_id, type: :binary_id
    belongs_to :internship_opening, UpaTikPortal.Recruitment.InternshipOpening, foreign_key: :opening_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end
  def changeset(internship_participation, attrs) do
    internship_participation
    |> cast(attrs, [:cv_url, :portfolio_url, :surat_pengantar_url, :transkrip_nilai_url, :university, :major, :status, :start_date, :end_date, :user_id, :opening_id])
    |> validate_required([:cv_url, :portfolio_url, :surat_pengantar_url, :transkrip_nilai_url, :university, :major, :start_date, :end_date, :user_id, :opening_id])
    |> validate_start_date()
    |> validate_end_date()
  end

  defp validate_start_date(changeset) do
    start_date = get_field(changeset, :start_date)

    if start_date && Date.compare(start_date, Date.utc_today()) != :gt do
      add_error(changeset, :start_date, "tanggal mulai harus lebih besar dari hari ini")
    else
      changeset
    end
  end

  defp validate_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    cond do
      is_nil(start_date) || is_nil(end_date) ->
        changeset

      Date.compare(end_date, Date.add(start_date, 120)) == :lt ->
        add_error(changeset, :end_date, "minimal 4 bulan dari tanggal mulai")

      true ->
        changeset
    end
  end
end
