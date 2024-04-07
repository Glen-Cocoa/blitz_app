To run the application in this repository
- define and make available an env var API_KEY containing a valid riot API key
- run `mix deps.get`
- run `mix run --no-halt`
  - for an interactive session, run `iex -S mix` instead

there is one `GET` route available:
  `localhost:8080/api/match_participants/:summoner_name/:summoner_region`

given a valid summoner name and region, this route will initially return a comma separated string of all the unique summoners the passed summoner name has played a match with in their last 5 games

these results will also be printed to the console

once per minute, a process will recheck for any new matches and print the `match_id` of any new match to the console

any request containing a summoner name that is not already being monitered will spawn an independant process for that new summoner

