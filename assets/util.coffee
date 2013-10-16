log = (msg) ->
  console.log msg

base_url =
  window.location.href.
    replace('://', '\\:').split('/')[0].
      replace('\\:', '://')

faye_url =
  base_url + '/faye'

faye_client_url =
  faye_url + '/client.js'

window.util = { log, faye_url, faye_client_url }
