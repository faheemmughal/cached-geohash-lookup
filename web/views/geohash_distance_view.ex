defmodule Maperoo.GeohashDistanceView do
  use Maperoo.Web, :view

  def render("index.json", %{geohash_distances: geohash_distances}) do
    %{data: render_many(geohash_distances, Maperoo.GeohashDistanceView, "geohash_distance.json")}
  end

  def render("show.json", %{geohash_distance: geohash_distance}) do
    %{data: render_one(geohash_distance, Maperoo.GeohashDistanceView, "geohash_distance.json")}
  end

  def render("geohash_distance.json", %{geohash_distance: geohash_distance}) do
    %{
      #start_point: geohash_distance.start_point,
      #end_point: geohash_distance.end_point,
      meters: geohash_distance.meters}
  end
end
