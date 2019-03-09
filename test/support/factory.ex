defmodule BinbaseBackend.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: BinbaseBackend.Repo

  alias BinbaseBackend.Accounts.User
  alias BinbaseBackend.Order
  alias BinbaseBackend.Orders
  
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
  def token() do
    user = insert_user()
    {:ok, u} = BinbaseBackend.Accounts.Users.sign_in(user.email, user.password)
    u.access_token
  end

  # Order factory

  def order_factory do
        %Order{
            token_rel: "BTC",
            token_base: "USDT",
            kind: 0,
            price: 3500,
            amount: 500,          
        }
  end
  def insert_order(id) do
    build(:order) |> Order.changeset(%{maker_id: id}) |> Ecto.Changeset.apply_changes() |> insert
  end  

end