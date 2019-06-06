defmodule Exchange.Trade do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :buy_id, :sell_id, :price, :amount, :fees_incl, :fees_excl, :updated_at, :inserted_at]}
  schema "trades" do
    field :buy_id, :integer
    field :sell_id, :integer
    field :price, :float
    field :amount, :float
    field :fees_incl, :float, default: 0.0
    field :fees_excl, :float, default: 0.0

    timestamps()
  end

  @required_fields ~w(sell_id buy_id price amount fees_incl fees_excl)a

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_fields)
  end

  def insert_all(trades) do
    Enum.map(trades, fn x -> %{x | fees_incl: calculate_fees(x)} end)
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn ({trade, index}, multi) ->
        changeset = Exchange.Trade.changeset(%Exchange.Trade{},Map.from_struct(trade))
        Ecto.Multi.insert(multi, Integer.to_string(index), changeset)
    end)
    |> Exchange.Repo.transaction()
  end

  @fixed_fees 0.01
  def calculate_fees(trade) do
    @fixed_fees / 100 * trade.amount
  end
end
