defmodule UpaTikPortal.RecruitmentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UpaTikPortal.Recruitment` context.
  """

  @doc """
  Generate a internship_opening.
  """
  def internship_opening_fixture(attrs \\ %{}) do
    {:ok, internship_opening} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> UpaTikPortal.Recruitment.create_internship_opening()

    internship_opening
  end
end
