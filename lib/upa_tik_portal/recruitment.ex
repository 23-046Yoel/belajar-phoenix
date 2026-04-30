defmodule UpaTikPortal.Recruitment do
  @moduledoc """
  The Recruitment context.
  """

  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo

  alias UpaTikPortal.Recruitment.InternshipOpening

  @doc """
  Returns the list of internship_openings.

  ## Examples

      iex> list_internship_openings()
      [%InternshipOpening{}, ...]

  """
  def list_internship_openings do
    Repo.all(InternshipOpening)
  end

  @doc """
  Gets a single internship_opening.

  Raises `Ecto.NoResultsError` if the Internship opening does not exist.

  ## Examples

      iex> get_internship_opening!(123)
      %InternshipOpening{}

      iex> get_internship_opening!(456)
      ** (Ecto.NoResultsError)

  """
  def get_internship_opening!(id), do: Repo.get!(InternshipOpening, id)

  @doc """
  Creates a internship_opening.

  ## Examples

      iex> create_internship_opening(%{field: value})
      {:ok, %InternshipOpening{}}

      iex> create_internship_opening(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_internship_opening(attrs) do
    IO.inspect(attrs, label: "ANJING")
    %InternshipOpening{}
    |> InternshipOpening.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a internship_opening.

  ## Examples

      iex> update_internship_opening(internship_opening, %{field: new_value})
      {:ok, %InternshipOpening{}}

      iex> update_internship_opening(internship_opening, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_internship_opening(%InternshipOpening{} = internship_opening, attrs) do
    internship_opening
    |> InternshipOpening.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a internship_opening.

  ## Examples

      iex> delete_internship_opening(internship_opening)
      {:ok, %InternshipOpening{}}

      iex> delete_internship_opening(internship_opening)
      {:error, %Ecto.Changeset{}}

  """
  def delete_internship_opening(%InternshipOpening{} = internship_opening) do
    Repo.delete(internship_opening)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking internship_opening changes.

  ## Examples

      iex> change_internship_opening(internship_opening)
      %Ecto.Changeset{data: %InternshipOpening{}}

  """
  def change_internship_opening(%InternshipOpening{} = internship_opening, attrs \\ %{}) do
    InternshipOpening.changeset(internship_opening, attrs)
  end
end
