defmodule BinbaseBackend.Balance do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @derive {Jason.Encoder, only: [:id, :user_id, :coin_id, :amount, :inserted_at, :updated_at]}
  schema "balances" do
    field :user_id, :integer
    field :coin_id, :integer
    field :amount, :float

    timestamps()
  end

  @required_fields ~w(user_id coin_id amount)a

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_fields)
  end

  def insert_balance(user_id, ticker, amount) do
    coin_id = BinbaseBackend.Utils.coin_id(ticker)

    %BinbaseBackend.Balance{}
    |> changeset(%{user_id: user_id, coin_id: coin_id, amount: amount})
    |> BinbaseBackend.Repo.insert()

  end

  def get_balance(user_id, ticker) do
    balances = get_balances(user_id, [ticker])
    balance = Enum.at(balances, 0)
    if balance == nil, do: 0.0, else: balance.amount
  end
  def get_balances(user_id, tickers) do
    coin_ids = Enum.map(tickers, fn x->
      BinbaseBackend.Utils.coin_id(x)
    end)
    BinbaseBackend.Balance
    |> where([b], b.user_id == ^user_id and b.coin_id in ^coin_ids)
    |> BinbaseBackend.Repo.all()
  end
end
