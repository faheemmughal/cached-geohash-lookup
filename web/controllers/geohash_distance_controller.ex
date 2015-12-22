defmodule Maperoo.GeohashDistanceController do
  use Maperoo.Web, :controller
  require Logger

  alias Maperoo.GeohashDistance

  import Maperoo.RateLimit
  plug :rate_limit, max_requests: 5, interval_seconds: 60

  def index(conn, %{"start_point" => start_point, "end_points" => end_points, "matrix" => "true"}) do
    # start_hash = GeoConversion.geohash_from_point(start_point)
    # end_hashes = GeoConversion.geohash_from_points(end_points)

    geohash_distances = calculate(%{start_hash: start_point, end_hashes: end_points})

    render(conn, "matrix.json", geohash_distance: geohash_distances)
  end

  # def index(conn, %{"start_point" => start_point, "end_points" => end_points}) do
  #   start_hash = GeoConversion.geohash_from_point(start_point)

  #   geohash_distances =
  #     end_points
  #     |> Enum.map(fn(end_point) ->
  #         distance(%{start_hash: start_hash, end_hash: GeoConversion.geohash_from_point(end_point)})
  #       end)
  #   render(conn, "index.json", geohash_distances: geohash_distances)
  # end

  # defp distance(hash_pair) do
  #   ConCache.get_or_store(:my_cache, hash_pair, fn ->
  #     Logger.debug "cache miss"
  #     fetch_or_calculate(hash_pair)
  #   end)
  # end

  # defp fetch_or_calculate(hash_pair) do
  #   case fetch_from_database(hash_pair) do
  #     nil ->
  #       Logger.debug "does not exist in database"
  #       # meters = calculate_distance(hash_pair)
  #       meters = compare(hash_pair)
  #       insert_in_database(hash_pair, meters)
  #     geohash_distance ->
  #       geohash_distance
  #     end
  # end

  # defp fetch_from_database(%{start_hash: start_hash, end_hash: end_hash}) do
  #   Repo.get_by(GeohashDistance, start_point: start_hash, end_point: end_hash)
  # end

  # defp insert_in_database(%{start_hash: start_hash, end_hash: end_hash}, meters) do
  #   %GeohashDistance{start_point: start_hash, end_point: end_hash, meters: meters}
  #   |> Repo.insert!
  # end

  defp calculate(hash_pairs) do
    matrix = OSRM.calculate(hash_pairs, :matrix)
  end

  # defp each_matrix_pair(hash_pairs, straight_line, road_distance)

  # def compare(hash_pair) do
  #   straight_line_distance = StraightLine.calculate(hash_pair)
  #   Logger.debug "Straight line distance is #{straight_line_distance}"

  #   compare(hash_pair, straight_line_distance, nil)
  # end

  # def compare(_hash_pair, straight_line_distance, _road_distance) when straight_line_distance > 10_000 do
  #   nil
  # end

  # def compare(hash_pair, straight_line_distance, nil) do
  #   road_distance = OSRM.calculate(hash_pair)
  #   Logger.debug "Road distance is #{road_distance}"

  #   compare(hash_pair, straight_line_distance, road_distance)
  # end

  # def compare(_hash_pair, straight_line_distance, road_distance) when road_distance > (2*straight_line_distance) do
  #   road_distance
  # end

  # def compare(_hash_pair, straight_line_distance, _road_distance) do
  #   straight_line_distance
  # end
end
