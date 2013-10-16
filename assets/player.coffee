#= require util

# global state
faye = null

# faye setup
$.getScript util.faye_client_url,  ->
  faye = new Faye.Client(util.faye_url)

  faye.subscribe "/pong/#{uuid}", (data) ->
    util.log "pong received with Team: #{data.team}"

  ping()
  setInterval ping, 5000

# game logic
ping = ->
  util.log 'ping'
  faye.publish '/ping', { uuid }

pseudo_uuid = -> # rfc 4122
  p = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  p.replace /[xy]/g, (c) ->
    r = Math.random() * 16 | 0
    v = if c=='x' then r else (r & 0x3 | 0x8)
    v.toString 16

get_uuid = ->
  uuid = localStorage.getItem 'uuid'
  uuid ?= pseudo_uuid()
  localStorage.setItem 'uuid', uuid
  uuid

uuid = get_uuid()

