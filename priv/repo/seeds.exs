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
alias BinbaseBackend.Order
alias BinbaseBackend.Accounts.Users

{_, data} = Users.create_user(%{email: "a@b.com", password: "123", invite_code: ""})

%Order{} 
|> Order.changeset(%{
    maker_id: data.id,
    token_rel: "BTC",
    token_base: "USDT",
    kind: 0,
    price: 4000,
    amount: 0.95,
})
|> Orders.create_order()

%Order{} 
|> Order.changeset(%{
    maker_id: data.id,
    token_rel: "BTC",
    token_base: "USDT",
    kind: 0,
    price: 4010,
    amount: 1.3,
})
|> Orders.create_order()

%Order{} 
|> Order.changeset(%{
    maker_id: data.id,
    token_rel: "BTC",
    token_base: "USDT",
    kind: 0,
    price: 4005,
    amount: 5.8,
})
|> Orders.create_order()


%Order{} 
|> Order.changeset(%{
    maker_id: data.id,
    token_rel: "BTC",
    token_base: "USDT",
    kind: 1,
    price: 4055,
    amount: 3.8,
})
|> Orders.create_order()

%Order{} 
|> Order.changeset(%{
    maker_id: data.id,
    token_rel: "BTC",
    token_base: "USDT",
    kind: 1,
    price: 4058,
    amount: 0.08,
})
|> Orders.create_order()

%Order{} 
|> Order.changeset(%{
    maker_id: data.id,
    token_rel: "BTC",
    token_base: "USDT",
    kind: 1,
    price: 4023,
    amount: 1.4,
})
|> Orders.create_order()