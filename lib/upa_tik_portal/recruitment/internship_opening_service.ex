defmodule UpaTikPortal.Recruitment.InternshipOpeningService do
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo

  alias UpaTikPortal.Recruitment.InternshipOpening

  def list_internship_openings do
    Repo.all(InternshipOpening)
  end

  def get_internship_opening!(id), do: Repo.get!(InternshipOpening, id)

  def create_internship_opening(attrs) do
    IO.inspect(attrs, label: "ANJING")
    %InternshipOpening{}
    |> InternshipOpening.changeset(attrs)
    |> Repo.insert()
  end

  def update_internship_opening(%InternshipOpening{} = internship_opening, attrs) do
    internship_opening
    |> InternshipOpening.changeset(attrs)
    |> Repo.update()
  end

  def delete_internship_opening(%InternshipOpening{} = internship_opening) do
    Repo.delete(internship_opening)
  end

  def change_internship_opening(%InternshipOpening{} = internship_opening, attrs \\ %{}) do
    InternshipOpening.changeset(internship_opening, attrs)
  end
end
