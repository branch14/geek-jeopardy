#= require util

# global state
players = {}
faye = null

# faye setup
$.getScript util.faye_client_url, ->
  faye = new Faye.Client(util.faye_url)
  faye.subscribe '/ping', (data) ->
    unless team = players[data.uuid]
      players[data.uuid] = team = pick_team()
    faye.publish "/pong/#{data.uuid}", { team }


# game logic
team_counts = ->
  counts = { a: 0, b: 0, c: 0 }
  counts[v]++ for k, v of players
  counts

pick_team = ->
  team = null
  min = null
  for k, v of team_counts()
    if min == null or v < min
      min = v
      team = k
  team

