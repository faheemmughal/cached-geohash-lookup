defmodule Maperoo.GeohashDistanceControllerTest do
  use Maperoo.ConnCase

  alias Maperoo.GeohashDistance
  @valid_attrs %{start_point: "51.485144,-0.171055", end_point: "51.495669,-0.141833", meters: 42 }
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "return -1 if no matches found", %{conn: conn} do
    conn = get conn, geohash_distance_path(conn, :index), [start_point: "54.485144,-0.191055", end_points: ["51.495669,-0.141833"]]
    assert json_response(conn, 200)["data"] == [%{"meters" => nil}]
  end

  test "return distance if matches found", %{conn: conn} do
    Repo.insert! %GeohashDistance{start_point: "gcpuuhe", end_point: "gcpuuy8", meters: 54}
    conn = get conn, geohash_distance_path(conn, :index), [start_point: "51.485144,-0.171055", end_points: ["51.495669,-0.141833"]]
    assert json_response(conn, 200)["data"] == [%{"meters" => 54}]
  end

  test "return distance from cache even if match is deleted", %{conn: conn} do
    Repo.insert! %GeohashDistance{start_point: "gcpuuhe", end_point: "gcpuuy8", meters: 54}
    conn = get conn, geohash_distance_path(conn, :index), [start_point: "51.485144,-0.171055", end_points: ["51.495669,-0.141833"]]
    assert json_response(conn, 200)["data"] == [%{"meters" => 54}]

    Repo.delete_all(GeohashDistance, start_point: "gcpuuhe", end_point: "gcpuuy8")
    conn = get conn, geohash_distance_path(conn, :index), [start_point: "51.485144,-0.171055", end_points: ["51.495669,-0.141833"]]
    assert json_response(conn, 200)["data"] == [%{"meters" => 54}]
  end


  test "return distances with multiple end points", %{conn: conn} do
    Repo.insert! %GeohashDistance{start_point: "gcpuuhe", end_point: "gcpuuy8", meters: 54}
    # missing middle one
    Repo.insert! %GeohashDistance{start_point: "gcpuuhe", end_point: "gcpvhb2", meters: 104}

    conn = get conn, geohash_distance_path(conn, :index), [start_point: "51.485144,-0.171055",
          end_points: ["51.495669,-0.141833", "71.515669,-0.141833", "51.505669,-0.141833"]]
    assert json_response(conn, 200)["data"] == [%{"meters" => 54}, %{"meters" => nil}, %{"meters" => 104}]
  end

  test "when distances does not exist, it calculates using OSRM API", %{conn: conn} do
    # start_hash = "r3gx27p"
    # end_hash = "r3gx2sr"
    conn = get conn, geohash_distance_path(conn, :index), [start_point: "-33.864957,151.192847", end_points: ["-33.857188,151.203576"]]
    assert json_response(conn, 200)["data"] == [%{"meters" => 3787}]
  end
end

