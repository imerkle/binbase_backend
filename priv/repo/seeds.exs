# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Exchange.Repo.insert!(%Exchange.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Exchange.Orders
alias Exchange.Accounts.Users
alias Exchange.Balance

{:ok, user} = Users.create_user(%{email: "a@b.com", password: "123", invite_code: ""})

{:ok, _} = Balance.insert_balance(user.id, "USDT", 20000)
{:ok, _} = Balance.insert_balance(user.id, "BTC", 2000)

defmodule Mord do
    def make_order([head | tail], data) do
        Orders.create_order(data.id, "BTC", "USDT", head["side"], head["price"], head["amount"])
        make_order(tail, data)
    end
    def make_order([], _) do
    end
end

x = [
    %{
        "side" => false,
        "price" => 4000.04,
        "amount" => 0.435
    },
    %{
        "side" => false,
        "price" => 4000.34,
        "amount" => 0.0455
    },
    %{
        "side" => false,
        "price" => 4002.84,
        "amount" => 3.867
    },
    %{
        "side" => false,
        "price" => 4011.67,
        "amount" => 1.545
    },
    %{
        "side" => false,
        "price" => 4010.31,
        "amount" => 0.5
    },
    %{
        "side" => false,
        "price" => 4000.04,
        "amount" => 1.5
    },
]
if Mix.env() == :dev do
    Mord.make_order(x, user)
end

