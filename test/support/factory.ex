defmodule BinbaseBackend.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: BinbaseBackend.Repo

  alias BinbaseBackend.Accounts.User
  
  @pass "pass"
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
    user = build(:user) |> set_password() |> insert
  end
  def token() do
    user = insert_user()
    {:ok, u} = BinbaseBackend.Accounts.Users.sign_in(user.email, user.password)
    u.access_token
  end
end