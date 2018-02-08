defmodule Example.MortalsTest do
  use Example.DataCase

  alias Example.Mortals

  describe "mortals" do
    alias Example.Mortals.Mortal

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def mortal_fixture(attrs \\ %{}) do
      {:ok, mortal} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Mortals.create_mortal()

      mortal
    end

    test "list_mortals/0 returns all mortals" do
      mortal = mortal_fixture()
      assert Mortals.list_mortals() == [mortal]
    end

    test "get_mortal!/1 returns the mortal with given id" do
      mortal = mortal_fixture()
      assert Mortals.get_mortal!(mortal.id) == mortal
    end

    test "create_mortal/1 with valid data creates a mortal" do
      assert {:ok, %Mortal{} = mortal} = Mortals.create_mortal(@valid_attrs)
      assert mortal.name == "some name"
    end

    test "create_mortal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mortals.create_mortal(@invalid_attrs)
    end

    test "update_mortal/2 with valid data updates the mortal" do
      mortal = mortal_fixture()
      assert {:ok, mortal} = Mortals.update_mortal(mortal, @update_attrs)
      assert %Mortal{} = mortal
      assert mortal.name == "some updated name"
    end

    test "update_mortal/2 with invalid data returns error changeset" do
      mortal = mortal_fixture()
      assert {:error, %Ecto.Changeset{}} = Mortals.update_mortal(mortal, @invalid_attrs)
      assert mortal == Mortals.get_mortal!(mortal.id)
    end

    test "delete_mortal/1 deletes the mortal" do
      mortal = mortal_fixture()
      assert {:ok, %Mortal{}} = Mortals.delete_mortal(mortal)
      assert_raise Ecto.NoResultsError, fn -> Mortals.get_mortal!(mortal.id) end
    end

    test "change_mortal/1 returns a mortal changeset" do
      mortal = mortal_fixture()
      assert %Ecto.Changeset{} = Mortals.change_mortal(mortal)
    end
  end
end
