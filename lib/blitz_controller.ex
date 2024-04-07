defmodule Blitz.RequestController do
  import Plug.Conn

  def process(conn, region, name) do
    case Blitz.RequestManager.server_process("#{region}:#{name}") do
      pid when is_pid(pid) ->
        participants = Blitz.RequestWorker.get_participants(pid)

        send_resp(
          conn,
          200,
          "Initial query results to return to caller: #{Enum.join(participants, ", ")}"
        )

      _ ->
        send_resp(
          conn,
          404,
          "Unable to complete query for name: #{name} region: #{region}"
        )
    end
  end
end
