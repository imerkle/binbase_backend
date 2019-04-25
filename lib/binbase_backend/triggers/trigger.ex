defmodule BinbaseBackend.Trigger do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :order_id, :trigger_at, :active]}
  schema "triggers" do
    field :order_id, :integer
    field :trigger_at, :float
    field :active, :boolean, default: true

    timestamps()
  end

  @required_fields ~w(order_id trigger_at active)a

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_fields)
  end
end
