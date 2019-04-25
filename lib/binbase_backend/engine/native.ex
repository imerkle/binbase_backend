defmodule BinbaseBackend.Engine.Native do
  use Rustler, otp_app: :binbase_backend, crate: :binbasebackend_engine_native

  defstruct orderbook: nil,
            orderbook_inverse: nil,
            trades: nil,
            order: nil,
            modified_orders: nil

  def match_order(_order, _orderbook, _orderbook_inverse), do: error()

  def error, do: :erlang.nif_error(:nif_not_loaded)
end
