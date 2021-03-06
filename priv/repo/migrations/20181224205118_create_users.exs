defmodule Exchange.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :encrypted_password, :string
      add :invited_by, :integer
      add :phishing_code, :string

      timestamps()
    end
    create unique_index(:users, [:email])
  end
end
