defmodule Exchange.Accounts.Users do
    import Ecto.Query, warn: false

  alias Exchange.Accounts.User
	alias Exchange.Errors
	alias Exchange.Emails

	#@max_age 86400
	@user_salt Application.get_env(:exchange, :phx_token_salt)
	def check_email(email) do
	user =  User
		|> where([u], u.email == ^email)
		|> Exchange.Repo.one()

		if user == nil do
			Errors.returnCode("user_not_found")
		else
			{:ok, %{"email" => user.email}}
		end
	end

	def create_user(%{email: email, password: password, invite_code: invite_code}) do
		user_changeset = User.changeset(%User{},%{email: email, password: password, invite_code: invite_code})

		Ecto.Multi.new()
		|> Ecto.Multi.insert(:user, user_changeset)
    |> Ecto.Multi.run(:access_token,fn _repo, %{user: user} ->
			token = Phoenix.Token.sign(ExchangeWeb.Endpoint, @user_salt, user.id)
			if Mix.env() == :prod do
				Emails.Email.welcome_email(email) |> Emails.Mailer.deliver_later
			end
			{:ok, token}
    end)
		|> Exchange.Repo.transaction()
		|> case do
			{:ok, result} ->
				{:ok, %{id: result.user.id, access_token: result.access_token}}
			{:error, _failed_operation, _failed_value, _changes} -> Errors.returnCode("user_already_exists")
		end
	end

	def sign_in(email, password) do
		with { :ok, user } <- authenticate_user(email, password) do
			token = Phoenix.Token.sign(ExchangeWeb.Endpoint, @user_salt, user.id)
			{:ok, %{id: user.id,access_token: token}}
		else
			_err -> Errors.returnCode("user_not_found")
		end
	end
	defp authenticate_user(email, given_password) do
	  User
	  |> where([u], u.email == ^email)
	  |> Exchange.Repo.one()
	  |> check_password(given_password)
	end

	defp check_password(nil, _), do: Errors.returnCode("user_not_found")
	defp check_password(user, given_password) do
	  case Comeonin.Argon2.checkpw(given_password, user.encrypted_password) do
	    true -> {:ok, user}
	    false -> Errors.returnCode("user_not_found")
	  end
	end
end
