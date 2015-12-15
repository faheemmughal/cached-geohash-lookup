defmodule Maperoo.Repo.Migrations.CreateGeohashDistance do
  use Ecto.Migration

  def change do
    create table(:geohash_distances, primary_key: false) do
      add :start_point, :char, size: 7
      add :end_point, :char, size: 7
      add :meters, :integer
    end

    create index(:geohash_distances, [:start_point, :end_point], unique: true)
  end
end
