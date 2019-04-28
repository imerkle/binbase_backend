defmodule BinbaseBackend.Repo.Migrations.CreateBalances do
  use Ecto.Migration

  def change do
    create table(:balances) do
      add :user_id, references(:users)
      add :coin_id, :integer
      add :amount, :float

      timestamps()
    end
  end
end
