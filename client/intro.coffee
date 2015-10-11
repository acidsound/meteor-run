Template.intro.onCreated ->
  @subscribe 'topRankBySteps', 5

Template.intro.helpers
  user: ->
    Meteor.user()
  leaderboards: ->
    idx = 0
    result = Leaderboard.find {},
      limit: 5
      sort:
        steps: -1
        speed: -1
    rankers = []
    idx = 0
    for rank in result.fetch()
      idx++
      rank.idx = idx
      rank.speed = (rank.speed * 1000).toFixed(2)
      rank.y = 34+(idx*8)
      rank.username = rank.user.username
      rankers.push rank
    rankers

Template.intro.events
  'click .leaderboards': (e, t)->
    e.preventDefault()

    $('.leaderboards').removeClass('show')
