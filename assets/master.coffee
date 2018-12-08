#= require util

# global state
players = {}
scores = { a: 0, b: 0, c: 0 }
active_player = null
active_category = null
active_level = null
faye = null
board = null

# setup state machine
fsm = StateMachine.create
  initial: 'initialize'
  events: [
    { name: 'start',          from: 'initialize',     to: 'select_clue' },
    { name: 'clue_selected',  from: 'select_clue',    to: 'read_clue' },
    { name: 'clue_read',      from: 'read_clue',      to: 'receive_buzz' },
    { name: 'buzz_received',  from: 'receive_buzz',   to: 'receive_answer' },
    { name: 'answer_wrong',   from: 'receive_answer', to: 'receive_buzz' },
    { name: 'answer_correct', from: 'receive_answer', to: 'select_clue' },
    { name: 'no_buzz',        from: 'receive_buzz',   to: 'select_clue' }
  ]
  callbacks:

    onselect_clue: ->
      $(".team").css color: 'black'
      $('#no_buzz, #controls').hide()
      $('#modal').removeClass('active')

    onclue_selected: (event, from, to, click_event) ->
      $(click_event.target).unbind 'click'
      target = $(click_event.target)
      md = target.attr('id').match(/^clue_(\d)_(\d)$/)
      active_category = parseInt(md[2]) - 1
      active_level = parseInt(md[1]) - 1
      target.attr "src", '/images/x.png'
      show_modal()
      $('#clue_read').show()

    onclue_read: ->
      $('#clue_read, #no_buzz').hide()
      $('#no_buzz').show()

    onreceive_buzz: ->
      $(".team").css color: 'black'
      $('#controls').hide()
      $('#no_buzz').show()

    onbuzz_received: (event, from, to, data) ->
      active_player = data.uuid
      team = players[active_player]
      $("#team-#{team} .team").css color: 'red'
      $('#controls').show()
      $('#no_buzz').hide()
      faye.publish "/state/#{active_player}", state: 'active'

    onanswer_correct: ->
      faye.publish "/state/#{active_player}", state: 'inactive'
      scores[players[active_player]] += value(active_level)
      show_scores()

    onanswer_wrong: ->
      faye.publish "/state/#{active_player}", state: 'inactive'
      scores[players[active_player]] -= value(active_level)
      show_scores()

value = (level) ->
  (level + 1) * 200

# faye setup
$.getScript util.faye_client_url, ->
  faye = new Faye.Client(util.faye_url)
  faye.subscribe '/ping', (data) ->
    unless team = players[data.uuid]
      players[data.uuid] = team = pick_team()
      show_teams()
    faye.publish "/pong/#{data.uuid}", { team }
  faye.subscribe '/buzz', (data) -> fsm.buzz_received(data)
  fsm.start()

# load board
$.getJSON '/javascripts/clues.json', (data) ->
  board = data
  for i in [0...6] # 6 categories
    $('#category_'+(i+1)).text(data.categories[i])

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

# display functions
show_scores = ->
  for team, score of scores
    $("#score-#{team}").text score

show_teams = ->
  for team, count of team_counts()
    $("#members-#{team}").text count

show_modal = ->
  $('#modal').addClass('active')
  $('#modal .modal_points').text value(active_level)
  $('#modal .modal_category').text board.categories[active_category]
  $('#modal .modal_clue').text board.clues[active_level][active_category]

# setup dom on document ready
$ ->
  $("#clue_read, #no_buzz, #controls").hide()

  $('.clue').click (e) -> fsm.clue_selected(e)
  $('#answer_correct').click -> fsm.answer_correct()
  $('#answer_wrong').click -> fsm.answer_wrong()
  $('#no_buzz').click -> fsm.no_buzz()
  $('#clue_read').click -> fsm.clue_read()
