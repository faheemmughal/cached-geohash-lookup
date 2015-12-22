defmodule GeoConversion do

  @precision 7

  def geohash_from_points(points) do
    points
    |> Enum.map(&geohash_from_point(&1))
  end

  def geohash_from_point(point) do
    [lat, long] = point
                  |> String.split(",")
                  |> Enum.map(&String.to_float(&1))

    Geohash.encode(lat, long, @precision)
  end

  def geohash_to_location_string(hash) do
    hash
    |> Geohash.decode
    |> Tuple.to_list
    |> Enum.join(",")
  end
end
