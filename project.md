**ASK:**
Given a valid `summoner_name` and `region`, fetch all summoners the given `summoner_name` has played in the last 5 matches
  - should be returned to caller as a list of summoner names
  - once a minute, for 60 minutes following the first call, check if any new matches have been played
  - when a new match is found, log to console as the string "Summoner <summoner name> completed match <match id>"

  structure so that any API key may be substituted

  Make use of Riot Developer API
  ○ https://developer.riotgames.com/apis
  ○ https://developer.riotgames.com/apissummoner-v4
  ○ https://developer.riotgames.com/apismatch-v5




TODO
- better error handling
- more tests
- add type specs & module docs