# Watch your language!

module.exports = (robot) ->

  class Violations
    constructor: (@robot) ->
      @robot.brain.data.swearwords = {}

    add: (badass, badword) ->
      @robot.brain.data.swearwords[badass.name] = (@robot.brain.data.swearwords[badass.name]+1) || 1

    getCount: (badass) ->
      return @robot.brain.data.swearwords[badass.name]

  quips =
    frequency  : 50
    thresholds :
      low  : 10
      high : 20
    messages   :
      low : [
        'Quite the mouth on you.',
        'You kiss your mother with that mouth?',
        'We are trying to be civilized around here.',
        'Watch yourself, there are ladies present.'
        ]
      high : [
        'Sailor, you are a long way from the docks, and that language does not fly around here.',
        'Holy shit.',
        '     ...wow'
      ]

  randomTruth = (freq) ->
    return Math.floor(Math.random() * 100) % Math.floor(100 / freq);

  violator = new Violations robot

  words = [
    'arse',
    'ass',
    'bastard',
    'bitch',
    'bugger',
    'bollocks',
    'bullshit',
    'cock',
    'cunt',
    'damn',
    'damnit',
    'dick',
    'douche',
    'fag',
    'fuck',
    'fucked',
    'fucking',
    'piss',
    'shit',
    'wank'
  ]
  regex = new RegExp('(?:^|\\s)(' + words.join('|') + ')(?:\\s|\\.|\\?|!|$)', 'i');

  robot.hear regex, (msg) ->
    violator.add msg.message.user, msg.match[1]

    count = violator.getCount msg.message.user
    if count == 1
      extra = "This is your first offense. Keep it clean from now on."
    else
      extra = "You have #{count} offenses. "

      if randomTruth quips.frequency
        quip = ""
        if count > quips.thresholds.low
          quip = msg.random quips.messages.low
        if count > quips.thresholds.high and randomTruth 75
          quip = msg.random quips.messages.high
        extra += quip

    msg.send "You have been fined one credit for a violation of the verbal morality statute. #{extra}"
