defmodule BinbaseBackend.Accounts.Users do
    import Ecto.Query, warn: false

  alias BinbaseBackend.Accounts.User
	alias BinbaseBackend.Errors
	
	@max_age 86400
	@user_salt Application.get_env(:binbase_backend, :phx_token_salt)
    def check_email(email) do 
	  user =  User
	    |> where([u], u.email == ^email)
	    |> BinbaseBackend.Repo.one()

			if user == nil do
				Errors.returnCode("not_found")
			else
				{:ok, %{"email" => user.email}}
			end        
    end
	def create_user(%{email: email, password: password, invite_code: invite_code}) do
		with {:ok, user} <- BinbaseBackend.Repo.insert(User.changeset(%User{},%{email: email, password: password, invite_code: invite_code})) do
		    token = Phoenix.Token.sign(BinbaseBackendWeb.Endpoint, @user_salt, user.id)
            {:ok, %{id: user.id, access_token: token}}
		else
			err -> Errors.returnCode()
		end
	end
	
	def sign_in(email, password) do
		with { :ok, user } <- authenticate_user(email, password) do
			token = Phoenix.Token.sign(BinbaseBackendWeb.Endpoint, @user_salt, user.id)
			{:ok, %{id: user.id,access_token: token}}
		else
			_err -> Errors.returnCode("not_found")
		end
	end	
	defp authenticate_user(email, given_password) do
	  User
	  |> where([u], u.email == ^email)
	  |> BinbaseBackend.Repo.one()
	  |> check_password(given_password)
	end

	defp check_password(nil, _), do: Errors.returnCode("not_found")
	defp check_password(user, given_password) do
	  case Comeonin.Argon2.checkpw(given_password, user.encrypted_password) do
	    true -> {:ok, user}
	    false -> Errors.returnCode("not_found")
	  end
	end	
end