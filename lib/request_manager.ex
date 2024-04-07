defmodule Blitz.RequestManager do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(name_region_key) do
    GenServer.call(__MODULE__, {:server_process, name_region_key})
  end

  def init(_arg) do
    {:ok, %{}}
  end

  def handle_call({:server_process, name_region_key}, _from, request_worker_servers) do
    case Map.fetch(request_worker_servers, name_region_key) do
      {:ok, worker} ->
        {:reply, worker, request_worker_servers}

      :error ->
        {:ok, new_worker} = Blitz.RequestWorker.start(name_region_key)

        {:reply, new_worker, Map.put(request_worker_servers, name_region_key, new_worker)}
    end
  end

  def handle_info({:complete, worker_pid}, request_worker_servers) do
    {key_to_delete, _v} = Enum.find(request_worker_servers, fn {_k, v} -> v == worker_pid end)
    updated_request_worker_servers = Map.delete(request_worker_servers, key_to_delete)
    {:noreply, updated_request_worker_servers}
  end
end
