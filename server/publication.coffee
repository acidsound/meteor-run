Meteor.publish 'topRankBySteps', (limit)->
  check limit, Number
  Leaderboard.find {},
    limit: limit
    sort:
      steps: -1
      speed: -1

Meteor.publish 'getTiles', (param)->
  Tiles.find
    c:
      $gte: ~~(+new Date()/constants.WorldsGenInterval)*constants.WorldsGenInterval
  ,
    sort:
      step: -1
    filter:
      tile: 1
Meteor.publish 'getTileCounts', (param)->
  tiles = Tiles.find
    c:
      $gte: ~~(+new Date()/constants.WorldsGenInterval)*constants.WorldsGenInterval
  Meteor.call 'setTiles', constants.initialTilesCounts if tiles.count() is 0
  Counts.publish @, 'tileCount', tiles

  return