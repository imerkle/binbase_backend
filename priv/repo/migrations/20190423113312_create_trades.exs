defmodule BinbaseBackend.Repo.Migrations.CreateTrades do
  use Ecto.Migration

  def change do
    create table(:trades) do
      add :sell_id, references(:orders)
      add :buy_id, references(:orders)
      add :price, :float
      add :amount, :float
      add :fees_incl, :float
      add :fees_excl, :float

      timestamps()
    end

  end
end
