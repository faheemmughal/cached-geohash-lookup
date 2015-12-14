defmodule Maperoo.GeohashDistanceController do
  use Maperoo.Web, :controller

  alias Maperoo.GeohashDistance

  plug :scrub_params, "geohash_distance" when action in [:create, :update]

  def index(conn, %{"start_point" => start_point, "end_point" => end_point}) do
    start_hash = start_point |> geohash
    end_hash = end_point |> geohash

    geohash_distances = ConCache.get_or_store(:my_cache, [start_hash, end_hash], fn ->
      Repo.all(GeohashDistance, start_point: geohash(start_point), end_point: geohash(end_point))
    end)

    render(conn, "index.json", geohash_distances: geohash_distances || [])
  end

  def geohash(point) do
    # IO.puts "point is #{point}"
    [lat, long] = String.split(point, ",")
                |> Enum.map(&String.to_float(&1))
    # IO.puts "lat is #{lat}, long is #{long}"
    hash = Geohash.encode(long, lat, 7)
    # IO.puts "hash is #{hash}"
    hash
  end

  # def create(conn, %{"geohash_distance" => geohash_distance_params}) do
  #   changeset = GeohashDistance.changeset(%GeohashDistance{}, geohash_distance_params)

  #   case Repo.insert(changeset) do
  #     {:ok, geohash_distance} ->
  #       conn
  #       |> put_status(:created)
  #       |> put_resp_header("location", geohash_distance_path(conn, :show, geohash_distance))
  #       |> render("show.json", geohash_distance: geohash_distance)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Maperoo.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  # def show(conn, %{"start_point" => start_point, "end_point" => end_point}) do

  #   geohash_distance = Repo.get_by!(GeohashDistance, start_point: start_point, end_point: end_point)
  #   render(conn, "show.json", geohash_distance: geohash_distance)
  # end

  # def update(conn, %{"id" => id, "geohash_distance" => geohash_distance_params}) do
  #   geohash_distance = Repo.get!(GeohashDistance, id)
  #   changeset = GeohashDistance.changeset(geohash_distance, geohash_distance_params)

  #   case Repo.update(changeset) do
  #     {:ok, geohash_distance} ->
  #       render(conn, "show.json", geohash_distance: geohash_distance)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Maperoo.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   geohash_distance = Repo.get!(GeohashDistance, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(geohash_distance)

  #   send_resp(conn, :no_content, "")
  # end
end
