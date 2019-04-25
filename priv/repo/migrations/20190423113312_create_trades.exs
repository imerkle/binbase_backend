defmodule BinbaseBackend.Repo.Migrations.CreateTrades do
  use Ecto.Migration

  def change do
    create table(:trades) do
      add :sell_id, references(:orders)
      add :buy_id, references(:orders)
      add :price, :float
      add :amount, :float

      timestamps()
    end

  end
end
