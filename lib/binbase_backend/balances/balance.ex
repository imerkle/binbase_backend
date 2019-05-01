defmodule BinbaseBackend.Balance do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key false
  @derive {Jason.Encoder, only: [:user_id, :coin_id, :amount, :inserted_at, :updated_at]}
  schema "balances" do
    field :user_id, :integer, primary_key: true
    field :coin_id, :integer, primary_key: true
    field :amount, :float
    field :amount_locked, :float

    timestamps()
  end

  @required_fields ~w(user_id coin_id amount)a

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_fields)
    |> unique_constraint(:user_id, name: :balances_user_id_coin_id_index)
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

  def get_balances(user_id, tickers, convert \\ true) do
    coin_ids = if convert do
      Enum.map(tickers, fn x->
        BinbaseBackend.Utils.coin_id(x)
      end)
    else
      tickers
    end
    BinbaseBackend.Balance
    |> where([b], b.user_id == ^user_id and b.coin_id in ^coin_ids)
    |> BinbaseBackend.Repo.all()
  end


  def update_all(balances) do
    Enum.with_index(balances)
    |> Enum.reduce(Ecto.Multi.new(), fn ({balance, index}, multi) ->
        index = Integer.to_string(index)
        Ecto.Multi.run(multi, index, fn repo, _ ->
          {update_count, _} = from(b in BinbaseBackend.Balance, update: [inc: [amount_locked: ^balance.amount, amount: ^-balance.amount]], where: b.user_id == ^balance.user_id and b.coin_id == ^balance.coin_id)
          |> repo.update_all([])
          {:ok, update_count}
        end)
    end)
    |> BinbaseBackend.Repo.transaction()
  end
end
