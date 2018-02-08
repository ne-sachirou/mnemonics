defmodule Example.Repo.Migrations.CreateMortals do
  use Ecto.Migration

  def change do
    create table(:mortals) do
      add :name, :string

      timestamps()
    end

  end
end
