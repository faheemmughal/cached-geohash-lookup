defmodule Maperoo.GeohashDistanceController do
  use Maperoo.Web, :controller

  alias Maperoo.GeohashDistance

  def index(conn, %{"start_point" => start_point, "end_points" => end_points}) do
    start_hash = geohash(start_point)

    geohash_distances =
      end_points
      |> Enum.map(fn(end_point) ->
          distance(start_hash, geohash(end_point))
        end)

    render(conn, "index.json", geohash_distances: geohash_distances)
  end

  defp geohash(point) do
    [lat, long] =
      String.split(point, ",")
      |> Enum.map(&String.to_float(&1))

    Geohash.encode(long, lat, 7)
  end

  defp distance(start_hash, end_hash) do
    ConCache.get_or_store(:my_cache, [start_hash, end_hash], fn ->
        Repo.get_by(GeohashDistance, start_point: start_hash, end_point: end_hash)
      end)
  end
end
