defmodule BinbaseBackend.Trade do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :buy_id, :sell_id, :price, :amount, :updated_at, :inserted_at]}
  schema "trades" do
    field :buy_id, :integer
    field :sell_id, :integer
    field :price, :float
    field :amount, :float

    timestamps()
  end

  @required_fields ~w(sell_id buy_id price amount)a

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_fields)
  end

  def insert_all(struct) do
    struct
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn ({trade, index}, multi) ->
        changeset = BinbaseBackend.Trade.changeset(%BinbaseBackend.Trade{},Map.from_struct(trade))
        Ecto.Multi.insert(multi, Integer.to_string(index), changeset)
    end)
    |> BinbaseBackend.Repo.transaction()
  end
end
