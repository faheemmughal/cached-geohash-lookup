defmodule Maperoo.GeohashDistanceController do
  use Maperoo.Web, :controller
  require Logger

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
    [long, lat] =
      String.split(point, ",")
      |> Enum.map(&String.to_float(&1))

    Geohash.encode(long, lat, 7)
  end

  defp distance(start_hash, end_hash) do
    ConCache.get_or_store(:my_cache, [start_hash, end_hash], fn ->
      Logger.debug "cache miss"
      fetch_or_calculate(start_hash, end_hash)
    end)
  end

  defp fetch_or_calculate(start_hash, end_hash) do
    case fetch_from_database(start_hash, end_hash) do
      nil ->
        Logger.debug "does not exist in database"
        meters = calculate_distance(start_hash, end_hash)
        geohash_distance = %GeohashDistance{start_point: start_hash, end_point: end_hash, meters: meters}
        Repo.insert!(geohash_distance)
        geohash_distance
      geohash_distance ->
        geohash_distance
      end
  end

  defp fetch_from_database(start_hash, end_hash) do
    Repo.get_by(GeohashDistance, start_point: start_hash, end_point: end_hash)
  end

  defp calculate_distance(start_hash, end_hash) do
    Logger.debug "calculating straight line distance between #{start_hash} and #{end_hash}"
    straight_line_distance = calculate_straight_line_distance(start_hash, end_hash)

    Logger.debug "Straight line distance is #{straight_line_distance}"
    if(straight_line_distance > 10_000) do
      nil
    else
      road_distance = calculate_road_distance(start_hash, end_hash)

      Logger.debug "Road distance is #{road_distance}"
      if road_distance > (2 * straight_line_distance) do
        road_distance
      else
        straight_line_distance
      end
    end
  end

  defp calculate_straight_line_distance(start_hash, end_hash) do
    query = "SELECT cast(
                ST_distance_sphere(
                  ST_PointFromGeoHash($1),
                  ST_PointFromGeoHash($2)
                ) as int)
              as distance"

    {:ok, %{rows: [[meters]]}} = Ecto.Adapters.SQL.query(Repo, query, [start_hash, end_hash])
    meters
  end

  defp calculate_road_distance(start_hash, end_hash) do
    OSRM.execute([start_hash, end_hash]) || 0
  end
end
