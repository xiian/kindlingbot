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
    @robot.brain.data.dbdelta_current = 0
    @robot.brain.data.dbdeltas = {}

  has: (deltanum) ->
    return (Number) deltanum of @robot.brain.data.dbdeltas

  list: ->
    return @robot.brain.data.dbdeltas or {}

  getNext: ->
    next = @robot.brain.data.dbdelta_current + 1
    next++ while next of @robot.brain.data.dbdeltas
    return next

  getCurrent: ->
    return @robot.brain.data.dbdelta_current

  setCurrent: (current) ->
    @robot.brain.data.dbdelta_current = (Number) current

  set: (deltanum, owner, reason) ->
    @robot.brain.data.dbdeltas[deltanum] =
      reason: reason
      owner: owner

  reassign: (original, newbie) ->
    if !@robot.brain.data.dbdeltas[original]
      return
    @robot.brain.data.dbdeltas[newbie] = @robot.brain.data.dbdeltas[original]
    delete @robot.brain.data.dbdeltas[original]

  setReason: (deltanum, reason) ->
    owner = @robot.brain.data.dbdeltas[deltanum].owner
    @set deltanum, owner, reason

  reserve: (reason, owner) ->
    deltanum = @getNext()
    @set deltanum, owner, reason
    return deltanum

  release: (deltanum) ->
    deltanum = (Number) deltanum
    delete @robot.brain.data.dbdeltas[deltanum]
    if deltanum is @robot.brain.data.dbdelta_current
      @robot.brain.data.dbdelta_current--

  shiftTo: (start, first, end) ->
    offset = start - first
    @reassign x, (offset) + x for x in [first..end]

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
    next = dbdeltas.getNext()
    message.push andbut + " the next one up for grabs is \##{next}"

    msg.send message.join(" ")

  # Shift
  robot.respond /shift dbdeltas ([0-9]+)-([0-9]+) to start at ([0-9]+)/i, (msg) ->
    first = (Number) msg.match[1]
    end   = (Number) msg.match[2]
    start = (Number) msg.match[3]
    dbdeltas.shiftTo start, first, end
    msg.send "Shifted DBDeltas #{first} through #{end} to start at \##{start}"

