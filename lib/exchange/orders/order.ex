defmodule Exchange.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Exchange.Utils
  alias Exchange.Balance

  @derive {Jason.Encoder, only: [:id, :maker_id, :market_id, :side, :kind, :price, :amount, :amount_filled, :active, :updated_at, :inserted_at]}
  schema "orders" do
    field :maker_id, :integer
    field :market_id, :integer
    field :side, :boolean
    field :kind, :integer, default: 0
    field :price, :float
    field :amount, :float
    field :amount_filled, :float, default: 0.0
    field :active, :boolean, default: true
    field :token_rel, :string, virtual: true
    field :token_base, :string, virtual: true

    timestamps()
  end

  @required_fields ~w(maker_id market_id side kind price amount amount_filled token_rel token_base)a

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_fields)
  end
  def new_changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_fields)
    |> put_market_id()
    |> check_balance()
  end
  defp put_market_id(changeset) do
    token_rel = get_field(changeset, :token_rel)
    token_base = get_field(changeset, :token_base)
    market_id = Utils.market_id(token_rel, token_base)

    put_change(changeset, :market_id, market_id)
  end
  defp check_balance(changeset) do

    token_rel = get_field(changeset, :token_rel)
    token_base = get_field(changeset, :token_base)
    side = get_field(changeset, :side)
    maker_id = get_field(changeset, :maker_id)
    amount = get_field(changeset, :amount)
    price = get_field(changeset, :price)

    {ticker, amount} =
    if side == false do
      {token_base, amount * price}
    else
      {token_rel, amount}
    end
    balance = Balance.get_balance(maker_id, ticker)

    if balance >= amount do
      changeset
    else
      add_error(changeset, :amount, "not_enough_balance",[type: :float, validation: :changeset])
    end
  end
end
