defmodule Exchange.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Exchange.Repo

  alias Exchange.Accounts.User
  alias Exchange.Order
  alias Exchange.Balance

  @pass "pass"

  # User factory

  def user_factory do
    %User{
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: @pass,
      invite_code: "",
    }
  end
  def set_password(user, password \\ @pass) do
      user
        |> User.changeset(%{invite_code: "", password: password})
        |> Ecto.Changeset.apply_changes()
  end

  def insert_user() do
    build(:user) |> set_password() |> insert
  end
  def token(fill_balance \\ 0) do
    user = insert_user()
    {:ok, u} = Exchange.Accounts.Users.sign_in(user.email, user.password)
    if fill_balance > 0 do
      {:ok, _} = Balance.insert_balance(user.id, "BTC", fill_balance)
      {:ok, _} = Balance.insert_balance(user.id, "USDT", fill_balance)
    end
    u.access_token
  end

  # Order factory

  def order_factory do
        %Order{
            token_rel: "BTC",
            token_base: "USDT",
            side: false,
            price: 3500,
            amount: 500,
        }
  end
  def insert_order(id) do
    build(:order) |> Order.changeset(%{maker_id: id}) |> Ecto.Changeset.apply_changes() |> insert
  end

end
