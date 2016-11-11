WebSocket = require 'ws'
common = require './common'
config = require '../config/config'
readline = require 'readline'

socket = null

lr = readline.createInterface process.stdin, process.stdout
lr.on 'line', (data)->
  common.sendMessage socket, data

foundMatch = null

connect = (address, handler)->
  if socket?
    socket.removeAllListeners()
    socket.close()
  socket = new WebSocket address


  socket.on 'open', ->
    console.log "connected to #{address}"
    if foundMatch?
      fm = foundMatch
      foundMatch = undefined
      common.sendMessage socket, {type: "join_game", matchId: fm.matchId}

  socket.on 'message', (data)->
    console.log data
    data = common.parseJson data

    if not data? then return console.log {type: 'error', data: 'invalid data'}

    if data.type is 'found_match'
      foundMatch = data
      connect data.server


connect config.matchMaker
