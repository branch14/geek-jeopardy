#= require util

# faye setup
$.getScript util.faye_client_url, ->
  faye = new Faye.Client(util.faye_url)
  faye.subscribe '/ping', (data) ->
    util.log "ping received with test_value: #{data.test_value}"
    faye.publish "/pong", team: 'A'
