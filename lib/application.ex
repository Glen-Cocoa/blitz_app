defmodule Blitz.Application do
  @moduledoc """
  this is the entry point of the application
  should start supervisor for the request process
  """
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Blitz.Router, options: [port: 8080]},
      {Blitz.RequestSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Blitz.RequestSupervisor]

    Logger.info("Starting Application")

    Supervisor.start_link(children, opts)
  end
end
