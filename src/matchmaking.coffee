ws = require 'ws'
shortid = require 'shortid'
config = require '../config/config'
common = require './common'


server = new ws.Server { port: 8080 }


serverIdx = 0
nextServer = ->
  idx = serverIdx
  serverIdx++
  if serverIdx >= config.gameServers.length then serverIdx = 0
  return config.gameServers[idx]



matchQueue = []

server.on 'connection', (socket)->
  socket.on 'message', (msg)->
    data = common.parseJson msg
    if not data? then return common.sendInvalid socket

    if data.type is "find_match"
      common.sendMessage socket, {type: 'success', data: "added to match queue"}
      return matchQueue.push socket
    return common.sendInvalid socket

  socket.on 'close', ->
    idx = matchQueue.indexOf socket
    if idx > -1
      matchQueue.splice idx, 1



console.log 'matchmaking server started at 8080'

matchmakingProcess = ->
  mq = matchQueue
  matchQueue = []

  if mq.length % 2 isnt 0
    matchQueue.push mq[mq.length - 1]

  halfLen = Math.floor mq.length * 0.5

  for idx in [0...halfLen]
    m1 = mq[idx * 2]
    m2 = mq[idx * 2 + 1]
    matchId = shortid.generate()
    message = {type: 'found_match', matchId: matchId, server: nextServer()}
    common.sendMessage m1, message
    common.sendMessage m2, message


setInterval matchmakingProcess, 500
