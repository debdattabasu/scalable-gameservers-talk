ws = require 'ws'
common = require './common'


port = process.argv[2]
port ?= 8081
server = new ws.Server { port: port }


games = {}

server.on 'connection', (socket)->
  socket.on 'message', (data)->
    data = common.parseJson data
    if not data? then return common.sendInvalid socket
    if data.type is "join_game"
      common.sendMessage socket, {type: 'success', data: "joined game #{data.matchId}"}
      if not games[data.matchId]? then games[data.matchId] = []
      games[data.matchId].push socket
      return socket.gameId = data.matchId

    if data.type is "chat_message"
      data.matchId = socket.gameId
      console.log data
      game = games[socket.gameId]
      if not game? then return
      return game.forEach (it)-> common.sendMessage it, data
    return common.sendInvalid socket

  socket.on 'close', ->
    if not socket.gameId? then return
    game = games[socket.gameId]
    if not game? then return

    idx = game.indexOf socket
    if idx > -1
      game.splice idx, 1

    if game.length is 0 then delete games[socket.gameId]



console.log "game server started at #{port}"
