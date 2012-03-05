# Michael Scott
#
# Keeps people in line, when they use too many "That's What She Said"

module.exports = (robot) ->
  michaels = [
    'http://i.imgur.com/CLsND.jpg',
    'http://i.imgur.com/jUiq0.jpg',
    'http://i.imgur.com/KeKAv.jpg',
    'http://i.imgur.com/lDkp8.jpg',
    'http://i.imgur.com/nBxSg.png',
    'http://i.imgur.com/nD27E.jpg',
    'http://i.imgur.com/P4UpH.jpg',
    'http://i.imgur.com/SkVKO.jpg',
    'http://i.imgur.com/tJSEb.jpg',
    'http://i.imgur.com/waKfs.jpg'
  ]
  robot.hear /that[']?s what she said/i, (msg) ->
    msg.send msg.random michaels
