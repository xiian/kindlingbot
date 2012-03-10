# Robots can"t fix everything

module.exports = (robot) ->
  excuses = [
    "Did you try turning it off and back on again?",
    "Needs moar jQuery.",
    "I created a GUI interface using visual basic to track the problem. Try zooming in and enhancing.",
    "Did you try blowing in it?",
    "When in doubt, shake it.",
    "It's probably <insert former coworker's name here>'s fault.",
    "Welp... now you've done it! You're asking the robot for help.",
    "uhhh... I didn't do it... Bye!",
    "I'm on my break. Get Linda to do it.",
    "I'm not even supposed to be here today!",
    "Oh, I'm sorry, I thought you were the developer and I was the cheeky robot. My mistake. Now get with the funny pictures!",
    "It's a UNIX system... I know this!",
    "Try running `rm -rf /` at the command line. That usually does it. I think.",
    "Sounds like you have a virus. Been to some of those naughty websites again?",
    "http://www.youtube.com/watch?v=ie4GN4J9lSQ",
    "Dammit, I'm a robot, not a... oh wait... maybe I should be able to do this."
  ]
  iCantFixIt = (msg) ->
    msg.send msg.random excuses

  robot.respond /fix it/i, (msg) ->
    iCantFixIt msg

  robot.respond /why won(')?t.*/i, (msg) ->
    iCantFixIt msg

  robot.respond /make it work/i, (msg) ->
    iCantFixIt msg
