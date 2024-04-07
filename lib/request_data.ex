defmodule Blitz.RequestData do
  defstruct summoner_data: %{},
            matches: [],
            participants: []

  def new(data) do
    %Blitz.RequestData{
      summoner_data: data.summoner_data,
      matches: data.matches,
      participants: data.participants
    }
  end

  def new() do
    %Blitz.RequestData{}
  end

  def get_match_differences(%Blitz.RequestData{} = old_data, %Blitz.RequestData{} = new_data) do
    old_matches = Enum.into(old_data.matches, MapSet.new())
    new_matches = Enum.into(new_data.matches, MapSet.new())
    MapSet.difference(new_matches, old_matches) |> MapSet.to_list()
  end
end
