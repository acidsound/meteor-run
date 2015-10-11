Meteor.methods
  'getServerTime': ->
    +new Date()
  'recordLeaderboard': (beginTime, steps, id, idx)->
    if @userId?
      endTime = +new Date()
      speed = steps / (endTime - beginTime)
      Leaderboard.insert
        user: Meteor.users.findOne @userId
        beginTime: beginTime
        endTime: endTime
        steps: steps
        speed: speed
      cnt = Leaderboard.find
        $and: [
          steps:
            $gte: steps
        ,
          speed:
            $lt: speed
        ]
      Tiles.update id,
        $addToSet:
          du:
            _id: @userId
            username: Meteor.users.findOne(@userId).username
            deadTile: idx
            deadAt: endTime
      rank : cnt.count()+1
  'doom': (pass)->
    if pass is 'doom'
      Leaderboard.remove {}
  'initTiles': ->
    Meteor.call 'addTile' for i in [0..constants.preloadBlockBuffer-1]
  'setTiles': (n)->
    Meteor.call 'addTile' for i in [0..n-1]
  'addTile': ->
    Tiles.insert
      c: +new Date()
      t: ~~(Math.random()*4)