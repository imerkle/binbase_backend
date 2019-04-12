defmodule BinbaseBackend.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :maker_id, references(:users)
      add :market_id, :integer
      add :kind, :integer
      add :price, :float
      add :amount, :float
      add :amount_filled, :float, default: 0
      add :stop_price, :float

      timestamps()
    end

  end
end