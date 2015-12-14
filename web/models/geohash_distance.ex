defmodule Maperoo.GeohashDistance do
  use Maperoo.Web, :model

  schema "geohash_distances" do
    field :start_point, :string
    field :end_point, :string
    field :meters, :integer

    timestamps
  end

  @required_fields ~w(start_point end_point meters)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
