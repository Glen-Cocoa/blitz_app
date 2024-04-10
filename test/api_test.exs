defmodule Blitz.APITest do
  use ExUnit.Case, async: false

  describe "API" do
    setup do
      %{
        region: "na1",
        name: "glencocoa"
      }
    end

    test "given a name and region, returns a list of summoner IDs", %{name: name, region: region} do
      {:ok,
       %{
         matches: matches,
         summoner_data: summoner_data,
         participants: participants
       }} = Blitz.API.run(name, region)

      assert length(matches) == 5
      assert is_list(participants) && length(participants) > 0
      assert summoner_data["name"] == name
    end
  end
end
