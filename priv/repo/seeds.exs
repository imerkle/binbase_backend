# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BinbaseBackend.Repo.insert!(%BinbaseBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias BinbaseBackend.Orders
alias BinbaseBackend.Accounts.Users

{_, data} = Users.create_user(%{email: "a@b.com", password: "123", invite_code: ""})

defmodule Mord do
    def make_order([head | tail], data) do
        Orders.create_order(data.id, "BTC", "USDT", head["kind"], head["price"], head["amount"])
        make_order(tail, data)
    end
    def make_order([], _) do
    end
end

x = [
    %{
        "kind" => 0,
        "price" => 4000.04,
        "amount" => 0.435
    },
    %{
        "kind" => 0,
        "price" => 4000.34,
        "amount" => 0.0455
    },    
    %{
        "kind" => 0,
        "price" => 4002.84,
        "amount" => 3.867
    },
    %{
        "kind" => 0,
        "price" => 4011.67,
        "amount" => 1.545
    },
    %{
        "kind" => 0,
        "price" => 4010.31,
        "amount" => 0.5
    },
    %{
        "kind" => 0,
        "price" => 4000.04,
        "amount" => 1.5
    },                
]
if Mix.env() == :dev do
    Mord.make_order(x, data)
end

