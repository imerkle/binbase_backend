defmodule BinbaseBackend.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :maker_id, references(:users)
      add :token_rel, :string, size: 4
      add :token_base, :string, size: 4
      add :kind, :integer
      add :price, :float
      add :amount, :float
      add :stop_price, :float

      timestamps()
    end

  end
end