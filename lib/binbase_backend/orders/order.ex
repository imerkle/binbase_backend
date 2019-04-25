defmodule BinbaseBackend.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :maker_id, :market_id, :kind, :price, :amount, :amount_filled, :active, :updated_at, :inserted_at]}
  schema "orders" do
    field :maker_id, :integer
    field :market_id, :integer
    field :kind, :boolean
    field :price, :float
    field :amount, :float
    field :amount_filled, :float, default: 0.0
    field :active, :boolean, default: true

    timestamps()
  end

  @required_fields ~w(maker_id market_id kind price amount amount_filled)a

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_fields)
  end
end
