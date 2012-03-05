# Keeps track of reserved DB Deltas
#
# These commands are grabbed from comment blocks at the top of each file.
#
# {reservations} give me a dbdelta for <reason> - Reserves next available DBDelta
# {reservations} give me dbdelta #<dbdelta> for <reason> - Reserves specific DBDelta
# {reservations} give up dbdelta <dbdelta> - Sets DBDelta as available
# {reservations} list dbdeltas - Lists available DBDeltas
# {reservations} set current dbdelta to <dbdelta> - Sets the current DBDelta
class DBDeltas
  constructor: (@robot) ->
    @current = 0
    @robot.brain.data.dbdeltas = {}

  has: (deltanum) ->
    return (Number) deltanum of @robot.brain.data.dbdeltas

  list: ->
    return @robot.brain.data.dbdeltas or {}

  setCurrent: (current) ->
    @current = (Number) current

  set: (deltanum, owner, reason) ->
    @robot.brain.data.dbdeltas[deltanum] =
      reason: reason
      owner: owner

  setReason: (deltanum, reason) ->
    owner = @robot.brain.data.dbdeltas[deltanum].owner
    @set deltanum, owner, reason

  reserve: (reason, owner) ->
    @current++
    @set @current, owner, reason
    return @current

  release: (deltanum) ->
    deltanum = (Number) deltanum
    delete @robot.brain.data.dbdeltas[deltanum]
    if deltanum is @current
      @current--

module.exports = (robot) ->
  dbdeltas = new  DBDeltas robot

  # Set current
  robot.respond /set current dbdelta to ([0-9]+)/i, (msg) ->
    dbdeltas.setCurrent msg.match[1]
    msg.send "Set the current DBDelta to #{msg.match[1]}"

  # Change reason
  robot.respond /change reason for dbdelta ([0-9]+) to (.*)/i, (msg) ->
    dbdelta = msg.match[1]
    reason  = msg.match[2]
    if dbdeltas.has(dbdelta)
      dbdeltas.setReason dbdelta, reason
      msg.send "Changed reason for #{dbdelta} to #{reason}"
    else
      msg.send "DBDelta \##{dbdelta} does not exist"

  # Reserve
  robot.respond /give me a dbdelta .*for (.+)/i, (msg) ->
    reason  = msg.match[1]
    owner   = msg.message.user
    dbdelta = dbdeltas.reserve reason, owner
    msg.send "#{owner.name} has reserved \##{dbdelta} for #{reason}"
    msg.finish()

  # Reserve specific
  robot.respond /give me dbdelta (#)?([0-9]+) for (.+)/i, (msg) ->
    reason  = msg.match[3]
    owner   = msg.message.user
    dbdelta = msg.match[2]
    dbdeltas.set dbdelta, owner, reason
    msg.send "#{owner.name} has reserved \##{dbdelta} for #{reason}"

  # Bad reserve
  robot.respond /give me a dbdelta/i, (msg) ->
    msg.reply "You have to give a reason for your reservation."

  # Un-reserve
  robot.respond /give up dbdelta ([0-9]+)/i, (msg) ->
    dbdeltas.release msg.match[1]
    msg.send "DBDelta \##{msg.match[1]} has been released to the wild"

  # List
  robot.respond /list dbdeltas/i, (msg) ->
    message = []
    deltas = dbdeltas.list()
    andbut = "and"
    if Object.keys(deltas).length > 0
      message.push "Here is a list of all reservations:\n"
      for num, delta of deltas
        message.push "\t* #{delta.owner.name} has DBDelta \##{num} for #{delta.reason}\n"
    else
      andbut = "but"
      message.push "No DBDeltas reserved"

    # Put out the next one
    next = dbdeltas.current + 1
    message.push andbut + " the next one up for grabs is \##{next}"

    msg.send message.join(" ")