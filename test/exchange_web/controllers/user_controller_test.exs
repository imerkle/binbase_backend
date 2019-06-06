defmodule ExchangeWeb.UserControllerTest do
  use ExchangeWeb.ConnCase

  import Exchange.Factory
  alias Exchange.Errors

  test "/create_user", %{conn: conn} do

      conn
      |> post(Routes.user_path(conn, :create_user, %{email: "jane@example.com", password: "jane pass", invite_code: ""}))
      |> json_response(200)
  end
  test "/create_user then /login", %{conn: conn} do

    user = insert_user()

    response =
      conn
      |> post(Routes.user_path(conn, :sign_in, %{"email" => user.email, "password" => user.password}))
      |> json_response(200)

    assert response["id"] == user.id
  end

  test "/check_email not_found", %{conn: conn} do
    response =
      conn
      |> get(Routes.user_path(conn, :check_email, %{"email" => "not_found@example.com"}))
      |> json_response(200)

      assert response == Errors.returnCodeBare("user_not_found")
  end

  test "/check_email works", %{conn: conn} do

    user = insert_user()

    test_email = %{"email" => user.email}
    response =
      conn
      |> get(Routes.user_path(conn, :check_email, test_email))
      |> json_response(200)

    assert response == test_email
  end
end
