defmodule GeoConversion do

  @precision 7

  def geohash_from_point(point) do
    [long, lat] =
      String.split(point, ",")
      |> Enum.map(&String.to_float(&1))

    Geohash.encode(long, lat, @precision)
  end

  def geohash_to_location_string(hash) do
    hash
    |> Geohash.decode
    |> Tuple.to_list
    |> Enum.join(",")
  end
end
