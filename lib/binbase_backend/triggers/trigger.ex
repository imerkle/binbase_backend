defmodule BinbaseBackend.Trigger do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @derive {Jason.Encoder, only: [:id, :market_id, :order_id, :trigger_at, :active]}
  schema "triggers" do
    field :market_id, :integer
    field :order_id, :integer
    field :trigger_at, :float
    field :active, :boolean, default: true

    timestamps()
  end

  @required_fields ~w(market_id order_id trigger_at active)a

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_fields)
  end
  def hit(market_id, my_price, last_price) do
    {low_price, high_price} = if my_price > last_price, do: {last_price, my_price}, else: {my_price, last_price}

    res = BinbaseBackend.Trigger
    |> join(:inner, [t], o in BinbaseBackend.Order, on: t.order_id == o.id)
    |> where([t], t.market_id == ^market_id and t.trigger_at >= ^low_price and t.trigger_at <= ^high_price and t.active == true)
    |> select([t, o], {t, o})
    |> BinbaseBackend.Repo.all()
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn ({ {trigger, order}, index}, multi) ->
      trigger_changeset = changeset(trigger,%{active: false})
      Ecto.Multi.update(multi, Integer.to_string(index), trigger_changeset)
      BinbaseBackend.Engine.match(order)
    end)

  end
end
