defmodule Maperoo.Repo.Migrations.CreateGeohashDistance do
  use Ecto.Migration

  def change do
    create table(:geohash_distances) do
      add :start_point, :string
      add :end_point, :string
      add :meters, :integer

      timestamps
    end

  end
end
