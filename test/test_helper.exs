{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start(trace: true)
Ecto.Adapters.SQL.Sandbox.mode(Exchange.Repo, :manual)
