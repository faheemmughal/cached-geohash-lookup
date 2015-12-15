defmodule OSRM do
  use HTTPoison.Base

  @base_url "http://192.168.99.100:5000/viaroute?"

  def execute(locations) do
    result = locations
    |> Enum.map(&hash_to_location_string(&1))
    |> query_params
    |> get!

    result.body
  end

  def process_url(url) do
    @base_url <> url
  end

  def process_response_body(body) do
    case Poison.decode!(body) do
      %{"status" => 207} ->
        nil
      %{"route_summary" => %{"total_distance" => distance}} ->
        distance
    end
  end


  defp query_params(locations) do
    location_params =
      locations
      |> Enum.map(fn(l) -> "loc=" <> l end)
      |> Enum.join("&")

    (location_params <> "&" <> options_params)
  end

  defp options_params do
    URI.encode_query(%{
      "output" => "json",
      "instructions" => "false",
      "geometry" => "false",
      "alt" => "false"})
  end

  defp hash_to_location_string(hash) do
    hash
    |> Geohash.decode
    |> Tuple.to_list
    |> Enum.join(",")
  end
end
