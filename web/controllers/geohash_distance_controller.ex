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
      fetch_or_calculate(start_hash, end_hash)
    end)
  end

  defp fetch_or_calculate(start_hash, end_hash) do
    case fetch_from_database(start_hash, end_hash) do
      nil ->
        distance = calculate_distance(start_hash, end_hash)
        geohash_distance = %GeohashDistance{start_point: start_hash, end_point: end_hash, meters: distance}
        Repo.insert!(geohash_distance)
        geohash_distance
      distance ->
        distance
      end
  end

  defp fetch_from_database(start_hash, end_hash) do
    Repo.get_by(GeohashDistance, start_point: start_hash, end_point: end_hash)
  end

  defp calculate_distance(start_hash, end_hash) do
    straight_line_distance = straight_line_distance(start_hash, end_hash)

    if straight_line_distance > 10_000 do
      nil
    else
      by_road_distance = by_road_distance(start_hash, end_hash)

      if by_road_distance > (2 * straight_line_distance) do
        by_road_distance
      else
        straight_line_distance
      end
    end
  end

  defp straight_line_distance(start_hash, end_hash) do
    query = "SELECT round(
              cast(
                ST_distance_sphere(
                  ST_PointFromGeoHash('$1'),
                  ST_PointFromGeoHash('$2')
                ) as numeric),
              2) as distance"

    {:ok, %{rows: [[distance]]}} = Ecto.Adapters.SQL.query(Repo, query, [start_hash, end_hash])
    distance
  end

  defp by_road_distance(start_hash, end_hash) do
    OSRM.execute(start_hash, end_hash) || 0
  end
end
