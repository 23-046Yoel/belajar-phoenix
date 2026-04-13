defmodule UpaTikPortal.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UpaTikPortal.Blog` context.
  """

  @doc """
  Generate a unique category title.
  """
  def unique_category_title, do: "some title#{System.unique_integer([:positive])}"

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        title: unique_category_title()
      })
      |> UpaTikPortal.Blog.create_category()

    category
  end
end
