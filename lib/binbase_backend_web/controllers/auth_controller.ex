defmodule BinbaseBackendWeb.AuthController do
  use BinbaseBackendWeb, :controller

  alias BinbaseBackend.Errors

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> json(Errors.returnCodeBare("invalid_auth"))
  end

end