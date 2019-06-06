defmodule ExchangeWeb.AuthController do
  use ExchangeWeb, :controller

  alias Exchange.Errors

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> json(Errors.returnCodeBare("invalid_auth"))
  end

end
