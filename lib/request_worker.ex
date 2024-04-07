defmodule Blitz.RequestWorker do
  use GenServer

  require Logger

  alias Blitz.API
  alias Blitz.RequestData

  @interval 60_000
  @cycle_limit 60

  defstruct cycles: 0, data: %Blitz.RequestData{}, name: nil, region: nil, error: nil

  @spec start(String.t()) :: {:error, term()} | {:ok, pid()}
  def start(name_region_key) do
    GenServer.start(__MODULE__, name_region_key)
  end

  @spec get_participants(pid()) :: [String.t()]
  def get_participants(pid) do
    GenServer.call(pid, :get_participants)
  end

  @spec init(String.t()) :: {:ok, %__MODULE__{}}
  def init(name_region_key) do
    [region, name] = String.split(name_region_key, ":")

    state = %__MODULE__{
      name: name,
      region: region,
      cycles: 0,
      data: RequestData.new()
    }

    Process.send_after(self(), :tick, @interval)

    case API.run(name, region) do
      {:ok, updated_data} ->
        Logger.debug(
          "Initial query results to return to caller: #{Enum.join(updated_data.participants, ", ")}"
        )

        {:ok, %{state | data: updated_data}}

      error ->
        {:ok, %{state | error: error}}
    end
  end

  @spec handle_call(:get_participants, _from :: pid(), %__MODULE__{}) ::
          {:reply, [String.t()], %__MODULE__{}}
  def handle_call(:get_participants, _from, state) do
    {:reply, state.data.participants, state}
  end

  @spec handle_info(:tick, %__MODULE__{}) ::
          {:stop, :normal, %__MODULE__{}} | {:noreply, %__MODULE__{}}
  def handle_info(:tick, %{error: error} = state) when not is_nil(error) do
    {:stop, :normal, state}
  end

  def handle_info(:tick, %{name: name, region: region, data: data, cycles: cycles} = state) do
    {:ok, updated_data} = API.run(name, region)

    Logger.info("checking for updated match list for summoner #{name}...")
    difference = RequestData.get_match_differences(data, updated_data)

    Enum.each(difference, fn match ->
      Logger.info("iteration #{cycles}: Summoner #{name} completed match #{match}")
    end)

    Process.send_after(self(), :tick, @interval)

    new_state = %{state | data: updated_data, cycles: cycles + 1}

    if new_state.cycles >= @cycle_limit,
      do: {:stop, :normal, state},
      else: {:noreply, new_state}
  end

  @spec terminate(atom(), %__MODULE__{}) :: :normal
  def terminate(_reason, %{error: error}) when not is_nil(error) do
    send(Blitz.RequestManager, {:complete, self()})
    Logger.debug("terminated with error: #{inspect(error)}")
    :normal
  end

  def terminate(reason, _state) do
    send(Blitz.RequestManager, {:complete, self()})
    Logger.info("terminated due to reason: #{inspect(reason)}")
    :normal
  end
end
