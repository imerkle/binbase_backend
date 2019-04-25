defmodule BinbaseBackend.Repo.Migrations.CreateTriggers do
  use Ecto.Migration

  def change do
    create table(:triggers) do
      add :market_id, :integer
      add :order_id, references(:orders)
      add :trigger_at, :float
      add :active, :boolean, default: true

      timestamps()
    end

  end
end
