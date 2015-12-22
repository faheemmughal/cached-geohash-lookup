defmodule StraightLine do
  alias Maperoo.Repo

  def calculate(%{start_hash: start_hash, end_hash: end_hash}) do
    {:ok, %{rows: [[meters]]}} = Ecto.Adapters.SQL.query(Repo, query, [start_hash, end_hash])
    meters
  end

  defp query do
    "SELECT cast(
        ST_distance_sphere(
          ST_PointFromGeoHash($1),
          ST_PointFromGeoHash($2)
        ) as int)
      as distance"
  end
end
