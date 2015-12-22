defmodule OSRM do
  use HTTPoison.Base

  require Logger

  @base_url "http://localhost:5000/"
  @viaroute "viaroute?"
  @matrix "table?"

  # def calculate(%{start_hash: start_hash, end_hash: end_hash}) do
  #   execute([start_hash, end_hash], @viaroute) || 0
  # end

  def calculate(%{start_hash: start_hash, end_hashes: end_hashes}, :matrix) do
    execute([start_hash|end_hashes], @matrix)
  end

  def execute(locations, service) do
    result = locations
      # |> Enum.map(&GeoConversion.geohash_to_location_string(&1))
      |> query_params(service)
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
      %{"route_summary" => %{"total_distance" => distance, "total_time" => time}} ->
        Logger.error "total_distance: #{distance}, total_time: #{time}"
        distance
      %{"distance_table" => distance_table} ->
        # Logger.error "distance table:"
        distance_table
    end
  end


  defp query_params(locations, service) do
    location_params =
      locations
      |> Enum.map(fn(l) -> "loc=" <> l end)
      |> Enum.join("&")

    (service <> location_params <> "&" <> options_params)
  end

  defp options_params do
    URI.encode_query(%{
      "output" => "json",
      "instructions" => "false",
      "geometry" => "false",
      "alt" => "false"})
  end

end
