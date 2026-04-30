defmodule UpaTikPortal.RecruitmentTest do
  use UpaTikPortal.DataCase

  alias UpaTikPortal.Recruitment

  describe "internship_openings" do
    alias UpaTikPortal.Recruitment.InternshipOpening

    import UpaTikPortal.RecruitmentFixtures

    @invalid_attrs %{title: nil}

    test "list_internship_openings/0 returns all internship_openings" do
      internship_opening = internship_opening_fixture()
      assert Recruitment.list_internship_openings() == [internship_opening]
    end

    test "get_internship_opening!/1 returns the internship_opening with given id" do
      internship_opening = internship_opening_fixture()
      assert Recruitment.get_internship_opening!(internship_opening.id) == internship_opening
    end

    test "create_internship_opening/1 with valid data creates a internship_opening" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %InternshipOpening{} = internship_opening} = Recruitment.create_internship_opening(valid_attrs)
      assert internship_opening.title == "some title"
    end

    test "create_internship_opening/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Recruitment.create_internship_opening(@invalid_attrs)
    end

    test "update_internship_opening/2 with valid data updates the internship_opening" do
      internship_opening = internship_opening_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %InternshipOpening{} = internship_opening} = Recruitment.update_internship_opening(internship_opening, update_attrs)
      assert internship_opening.title == "some updated title"
    end

    test "update_internship_opening/2 with invalid data returns error changeset" do
      internship_opening = internship_opening_fixture()
      assert {:error, %Ecto.Changeset{}} = Recruitment.update_internship_opening(internship_opening, @invalid_attrs)
      assert internship_opening == Recruitment.get_internship_opening!(internship_opening.id)
    end

    test "delete_internship_opening/1 deletes the internship_opening" do
      internship_opening = internship_opening_fixture()
      assert {:ok, %InternshipOpening{}} = Recruitment.delete_internship_opening(internship_opening)
      assert_raise Ecto.NoResultsError, fn -> Recruitment.get_internship_opening!(internship_opening.id) end
    end

    test "change_internship_opening/1 returns a internship_opening changeset" do
      internship_opening = internship_opening_fixture()
      assert %Ecto.Changeset{} = Recruitment.change_internship_opening(internship_opening)
    end
  end
end
