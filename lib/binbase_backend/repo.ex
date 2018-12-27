defmodule BinbaseBackend.Repo do
  use Ecto.Repo,
    otp_app: :binbase_backend,
    adapter: Ecto.Adapters.Postgres
end
