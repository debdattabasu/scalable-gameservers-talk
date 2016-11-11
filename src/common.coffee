exports.parseJson = (json)->
  try
    json =  JSON.parse json
    if typeof json is 'string' then json = JSON.parse json
    return json
  catch error
    return undefined


exports.sendMessage = (socket, msg)->
  try
    msg = if typeof data is 'string' then msg else JSON.stringify msg
    socket.send msg
  catch error


exports.sendInvalid = (socket)->
  exports.sendMessage socket, {type: 'error', message: 'invalid input format'}
