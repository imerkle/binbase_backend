defmodule BinbaseBackend.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:maker_id, :market_id, :kind, :price, :amount, :amount_filled, :stop_price, :updated_at, :inserted_at]}
  schema "orders" do
    field :maker_id, :integer
    field :market_id, :integer
    field :kind, :integer
    field :price, :float
    field :amount, :float
    field :amount_filled, :float
    field :stop_price, :float #stop loss trigger

    timestamps()
  end

  @required_fields ~w(maker_id market_id kind price amount)a
  @optional_fields ~w(stop_price amount_filled)

  @doc false
  def changeset(orders, attrs) do
    orders
    |> cast(attrs, @required_fields, @optional_fields)
  end
end