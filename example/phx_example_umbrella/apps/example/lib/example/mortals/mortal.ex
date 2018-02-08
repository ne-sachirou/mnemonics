defmodule Example.Mortals.Mortal do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Example.Mortals.Mortal

  schema "mortals" do
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(%Mortal{} = mortal, attrs) do
    mortal
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
