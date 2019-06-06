defmodule Exchange.Utils do

    @rel ["BTC","ETH"]
    @base ["USDT","BTC"]
    @coins ["USDT","BTC", "ETH"]

    def market_id(token_rel, token_base) do
        ri = find_indexes(@rel, fn(x) -> x == token_rel end)
        bi = find_indexes(@base, fn(x) -> x == token_base end)
        ri + bi*100
    end

    def coin_id(ticker) do
        find_indexes(@coins, fn(x) -> x == ticker end)
    end

    defp find_indexes(collection, function) do
        do_find_indexes(collection, function)
    end
    defp do_find_indexes(collection, function, counter \\ 0)
    defp do_find_indexes([h|t], function, counter) do
        if function.(h) do
            counter
        else
            do_find_indexes(t, function, counter + 1)
        end
    end
    defp do_find_indexes([], _function, _counter) do
        nil
    end

end
