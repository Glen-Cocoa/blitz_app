defmodule Blitz.API do
  # not sure what regions should be mapped where
  @region_dict %{
    "na1" => "americas",
    "br1" => "americas",
    "eun1" => "europe",
    "euw1" => "europe",
    "jp1" => "asia",
    "kr" => "asia",
    "la1" => "americas",
    "la2" => "americas",
    "oc1" => "asia",
    "ru" => "asia",
    "tr1" => "europe",
    "tw2" => "asia",
    "vn2" => "asia",
  }

  def run(name, region) do
    with {:ok, summoner_data} <- get_summoner_data(name, region),
         {:ok, matches} <- get_last_five_matches(summoner_data, @region_dict[region]),
         {:ok, participants} <- get_unique_participants(matches, @region_dict[region]) do
      {:ok,
       Blitz.RequestData.new(%{
         summoner_data: summoner_data,
         matches: matches,
         participants: participants
       })}
    end
  end

  defp get_summoner_data(summoner_name, summoner_region) do
    url =
      "#{base_url(summoner_region)}/summoner/v4/summoners/by-name/#{summoner_name}?api_key=#{api_key()}"

    make_request(url)
  end

  defp get_last_five_matches(summoner_data, summoner_region) do
    puuid = Map.get(summoner_data, "puuid")

    url =
      "#{base_url(summoner_region)}/match/v5/matches/by-puuid/#{puuid}/ids?count=5&api_key=#{api_key()}"

    make_request(url)
  end

  defp get_unique_participants(matches, summoner_region) do
    participants =
      matches
      |> Enum.reduce([], fn current_match_id, acc ->
        url =
          "#{base_url(summoner_region)}/match/v5/matches/#{current_match_id}?api_key=#{api_key()}"

        {:ok, %{"metadata" => %{"participants" => participants}}} = make_request(url)

        Enum.concat(acc, participants)
      end)
      |> Enum.uniq()

    {:ok, participants}
  end

  defp api_key() do
    Application.get_env(:blitz, :api_key)
  end

  defp base_url(region) do
    "https://#{region}.api.riotgames.com/lol"
  end

  defp make_request(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "HTTP request failed with status code #{code} and body #{body}"}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
