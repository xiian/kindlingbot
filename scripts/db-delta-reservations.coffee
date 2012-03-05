# Keeps track of reserved DB Deltas
#
# These commands are grabbed from comment blocks at the top of each file.
#
# {reservations} give me a dbdelta for <reason> - Reserves next available DBDelta
# {reservations} give up dbdelta <dbdelta> - Sets DBDelta as available
# {reservations} list dbdeltas - Lists available DBDeltas
# {reservations} set current dbdelta to <dbdelta> - Sets the current DBDelta
class DBDeltas
  constructor: (@robot) ->
    @current = 0
    @robot.brain.data.dbdeltas = {}

  list: ->
    return @robot.brain.data.dbdeltas or {}

  setCurrent: (current) ->
    @current = (Number) current

  set: (dbdelta, owner, reason) ->
    @robot.brain.data.dbdeltas[dbdelta] =
      reason: reason
      owner: owner

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

  # Reserve
  robot.respond /give me a dbdelta .*for (.+)/i, (msg) ->
    reason  = msg.match[1]
    owner   = msg.message.user
    dbdelta = dbdeltas.reserve reason, owner
    msg.send "#{owner.name} has reserved \##{dbdelta} for #{reason}"
    msg.finish()

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