defmodule BinbaseBackend.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:maker_id, :token_rel, :token_base, :kind, :price, :amount, :stop_price, :updated_at, :inserted_at]}
  schema "orders" do
    field :maker_id, :integer
    field :token_rel, :string
    field :token_base, :string
    field :kind, :integer
    field :price, :float
    field :amount, :float
    field :stop_price, :float #stop loss trigger

    timestamps()
  end

  @required_fields ~w(maker_id token_rel token_base kind price amount stop_price)a
#  @optional_fields ~w()

  @doc false
  def changeset(orders, attrs) do
    orders
    |> cast(attrs, @required_fields)
    |> validate_tokens()
  end

  @base_list ["USDT"]
  @rel_list %{
  	"USDT"=>["BTC"],
	}

  defp validate_tokens(changeset) do

  	rel = get_field(changeset, :token_rel)
  	base = get_field(changeset, :token_base)

  	if base in @base_list && rel in @rel_list[base] , do: changeset, else: token_incorrect_error(changeset)
  end

  defp token_incorrect_error(changeset) do
    add_error(changeset, :token_rel, "is not valid")
  end

end