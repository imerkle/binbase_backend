defmodule BinbaseBackend.Utils do
    
    @rel ["BTC","ETH"]
    @base ["USDT","BTC"]

    def market_id(token_rel, token_base) do
        ri = find_indexes(@rel, fn(x) -> x == token_rel end)
        bi = find_indexes(@base, fn(x) -> x == token_base end)
        x = Integer.to_string(ri) <> Integer.to_string(bi)
        x |> Integer.parse() |> elem(0)
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

    def inverse_int(n) do
        if n==0, do: 1, else: 0
    end    
end