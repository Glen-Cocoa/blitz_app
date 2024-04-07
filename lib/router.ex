defmodule Blitz.Router do
  use Plug.Router

  alias Blitz.RequestController

  plug(:match)
  plug(:dispatch)

  get "/api/match_participants/:name/:region" do
    RequestController.process(conn, conn.params["region"], conn.params["name"])
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
