defmodule BinbaseBackend.Repo.Migrations.CreateBalances do
  use Ecto.Migration

  def change do
    create table(:balances, primary_key: false) do
      add :user_id, references(:users), primary_key: true
      add :coin_id, :integer, primary_key: true
      add :amount, :float
      add :amount_locked, :float

      timestamps()
    end
    create unique_index(:balances, [:user_id, :coin_id], [name: :balances_user_id_coin_id_index])
  end
end
