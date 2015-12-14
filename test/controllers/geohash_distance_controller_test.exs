defmodule Maperoo.GeohashDistanceControllerTest do
  use Maperoo.ConnCase

  alias Maperoo.GeohashDistance
  @valid_attrs %{end_point: "some content", meters: 42, start_point: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, geohash_distance_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    geohash_distance = Repo.insert! %GeohashDistance{}
    conn = get conn, geohash_distance_path(conn, :show, geohash_distance)
    assert json_response(conn, 200)["data"] == %{"id" => geohash_distance.id,
      "start_point" => geohash_distance.start_point,
      "end_point" => geohash_distance.end_point,
      "meters" => geohash_distance.meters}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, geohash_distance_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, geohash_distance_path(conn, :create), geohash_distance: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(GeohashDistance, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, geohash_distance_path(conn, :create), geohash_distance: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    geohash_distance = Repo.insert! %GeohashDistance{}
    conn = put conn, geohash_distance_path(conn, :update, geohash_distance), geohash_distance: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(GeohashDistance, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    geohash_distance = Repo.insert! %GeohashDistance{}
    conn = put conn, geohash_distance_path(conn, :update, geohash_distance), geohash_distance: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    geohash_distance = Repo.insert! %GeohashDistance{}
    conn = delete conn, geohash_distance_path(conn, :delete, geohash_distance)
    assert response(conn, 204)
    refute Repo.get(GeohashDistance, geohash_distance.id)
  end
end
