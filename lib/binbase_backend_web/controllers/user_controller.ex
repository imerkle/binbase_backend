defmodule BinbaseBackendWeb.UserController do
  use BinbaseBackendWeb, :controller
	
	alias BinbaseBackend.Accounts.Users
	def check_email(conn, %{"email" => email}) do
		{_, data} = Users.check_email(email)
	  json(conn, data)
	end
	def create_user(conn, %{"email"=> email,"password"=> password,"invite_code"=> invite_code}) do
		{_, data} = Users.create_user(%{email: email, password: password, invite_code: invite_code})
	  json(conn, data)
	end
	def sign_in(conn, params) do
		{_, data} = Users.sign_in(params["email"], params["password"])
	  json(conn, data)
	end
	@version Mix.Project.config[:version]
	def version(conn, _) do
		json(conn, %{"version"=>@version})
	end

end