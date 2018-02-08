defmodule Example.Mortals do
  @moduledoc """
  The Mortals context.
  """

  import Ecto.Query, warn: false
  alias Example.Repo

  alias Example.Mortals.Mortal

  @doc """
  Returns the list of mortals.

  ## Examples

      iex> list_mortals()
      [%Mortal{}, ...]

  """
  def list_mortals do
    Repo.all(Mortal)
  end

  @doc """
  Gets a single mortal.

  Raises `Ecto.NoResultsError` if the Mortal does not exist.

  ## Examples

      iex> get_mortal!(123)
      %Mortal{}

      iex> get_mortal!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mortal!(id), do: Repo.get!(Mortal, id)

  @doc """
  Creates a mortal.

  ## Examples

      iex> create_mortal(%{field: value})
      {:ok, %Mortal{}}

      iex> create_mortal(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mortal(attrs \\ %{}) do
    %Mortal{}
    |> Mortal.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mortal.

  ## Examples

      iex> update_mortal(mortal, %{field: new_value})
      {:ok, %Mortal{}}

      iex> update_mortal(mortal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mortal(%Mortal{} = mortal, attrs) do
    mortal
    |> Mortal.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Mortal.

  ## Examples

      iex> delete_mortal(mortal)
      {:ok, %Mortal{}}

      iex> delete_mortal(mortal)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mortal(%Mortal{} = mortal) do
    Repo.delete(mortal)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mortal changes.

  ## Examples

      iex> change_mortal(mortal)
      %Ecto.Changeset{source: %Mortal{}}

  """
  def change_mortal(%Mortal{} = mortal) do
    Mortal.changeset(mortal, %{})
  end
end
