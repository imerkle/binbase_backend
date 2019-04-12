defmodule BinbaseBackend.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string
    field :invited_by, :integer
    field :invite_code, :string, virtual: true
    field :phishing_code, :string

    timestamps()
  end

  @salt Hashids.new([
    salt: Application.get_env(:binbase_backend, :hashid_salt),
    min_len: 10,
  ])

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :encrypted_password])
    |> validate_length(:password, min: 0)
    #|> validate_required([:email, :encrypted_password])
    |> unique_constraint(:email)
    |> put_change(:encrypted_password, Comeonin.Argon2.hashpwsalt(attrs[:password]))
    |> put_invite(attrs[:invite_code])
    |> put_change(:phishing_code, :rand.uniform(10000) |> Integer.to_string() )
  end

  defp put_invite(cset, invite_code) do
    if invite_code != "" do
      cset |> put_change(:invited_by, Hashids.decode(@salt, invite_code))
    end || cset
  end

end