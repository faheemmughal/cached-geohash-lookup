defmodule Maperoo.Repo.Migrations.AddPostgisExtension do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION postgis"
  end
end
