defmodule Maperoo.GeohashDistanceTest do
  use Maperoo.ModelCase

  alias Maperoo.GeohashDistance

  @valid_attrs %{end_point: "some content", meters: 42, start_point: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GeohashDistance.changeset(%GeohashDistance{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GeohashDistance.changeset(%GeohashDistance{}, @invalid_attrs)
    refute changeset.valid?
  end
end
