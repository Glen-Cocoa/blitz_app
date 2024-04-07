defmodule Blitz.RequestSupervisor do
  use Supervisor

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state)
  end

  def init(_args) do
    children = [
      %{
        id: Blitz.RequestManager,
        start: {Blitz.RequestManager, :start_link, []},
        restart: :transient
      }
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
