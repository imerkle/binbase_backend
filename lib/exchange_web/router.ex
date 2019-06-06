defmodule ExchangeWeb.Router do
  use ExchangeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

    plug PhoenixTokenPlug.VerifyHeader,
      salt: Application.get_env(:exchange, :phx_token_salt),
      max_age: 1_209_600
  end

  pipeline :api_stateless do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    # Checks if conn.assigns.user exists; if not, will
    # call ExchangeWeb.AuthController.unauthenticated/2
    plug PhoenixTokenPlug.EnsureAuthenticated,
      handler: ExchangeWeb.AuthController # Or any other module
  end

  scope "/", ExchangeWeb do
    pipe_through :api_stateless #we dont need authentication here

    get "/version", UserController, :version

    get "/check_email", UserController, :check_email
    post "/create_user", UserController, :create_user
    post "/sign_in", UserController, :sign_in

    get "/get_orders", OrderController, :get_orders
  end

  scope "/", ExchangeWeb do
    pipe_through [:api, :protected]

    #get "/users/:id", UserController, :show

    post "/create_order", OrderController, :create_order
  end
end
