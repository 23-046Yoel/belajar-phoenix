defmodule UpaTikPortal.Recruitment.InternshipParticipationService do
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias Ecto.Multi
  alias UpaTikPortal.Recruitment.InternshipParticipation
  alias UpaTikPortal.Recruitment.InternshipOpening

  def get_internship_participation!(id), do: Repo.get!(InternshipParticipation, id)

  def create_internship_participation(attrs) do
    Multi.new()
    # 1. Operasi Insert Lamaran
    |> Multi.insert(
      :participation,
      InternshipParticipation.changeset(%InternshipParticipation{}, attrs)
    )
    # 2. Operasi Update Kuota (Mengurangi 1)
    |> Multi.update_all(
      :decrement_quota,
      fn %{participation: p} ->
        from(o in InternshipOpening,
          where: o.id == ^p.opening_id and o.quota > 0,
          update: [inc: [quota: -1]]
        )
      end,
      []
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{participation: participation}} ->
        {:ok, participation}

      {:error, :participation, changeset, _steps} ->
        {:error, changeset}

      {:error, :decrement_quota, _reason, _steps} ->
        {:error, :quota_full}
    end
  end

  def change_internship_participation(
        %InternshipParticipation{} = internship_participation,
        attrs \\ %{}
      ) do
    InternshipParticipation.changeset(internship_participation, attrs)
  end
end
