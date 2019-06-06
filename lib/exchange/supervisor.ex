defmodule Exchange.MainSupervisor do
  use Supervisor

  import Supervisor.Spec



  @doc "Start the Supervisor"
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end





  ## Callbacks
  ## ---------


  def init(_arg) do
    children(:engine)
    |> Supervisor.init(strategy: :one_for_one)
  end





  ## Children Spec
  ## -------------


  # Children for Engine Mode
  defp children(:engine) do
    [
      # Start the Ecto repository
      supervisor(Exchange.Repo, []),
      worker(Exchange.Rabbit.Broadcaster, []),
      worker(Exchange.Rabbit.Listener, []),
    ]
  end

  # Raise error for other modes
  defp children(_mode) do
    raise "Supervision Tree not defined for specified mode"
  end


end
