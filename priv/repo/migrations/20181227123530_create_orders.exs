defmodule Exchange.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :maker_id, references(:users)
      add :market_id, :integer
      add :side, :boolean
      add :kind, :integer
      add :price, :float
      add :amount, :float
      add :amount_filled, :float
      add :active, :boolean

      timestamps()
    end

  end
end
