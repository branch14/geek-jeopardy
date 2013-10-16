#= require util

# global state
faye = null

# faye setup
$.getScript util.faye_client_url,  ->
  faye = new Faye.Client(util.faye_url)

  faye.subscribe "/pong", (data) ->
    util.log "pong received with Team #{data.team}"

  ping()
  setInterval ping, 5000

# game logic
ping = ->
  util.log 'ping'
  faye.publish '/ping', test_value: 'test_key'

