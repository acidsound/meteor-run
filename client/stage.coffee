addCondition = (currentStep, tileCount)->
  (currentStep + constants.preloadBlockBuffer/2) >= tileCount
tapEffect = (e) ->
  placement =
    left: e.clientX or e.originalEvent.touches[0].pageX
    top:  e.clientY or e.originalEvent.touches[0].pageY

  replica = document.createElement('div')

  $(replica).css(
    'top': placement.top
    'left': placement.left
  ).addClass('fade')

  $('body').after(replica)

  setTimeout ->
    $(replica).addClass('tapped')
  , 0

  $(replica).one constants.transitionEnd, ->
    $(replica).remove()
showScoreModal = (e) ->
  $('.modal').addClass('modal-show')
  $(e.target).addClass('die')

Template.stage.onCreated ->
  @beginTime = 0
  @sDelta = 0
  @prevTime = 0
  @currentTime = 0
  @steps = new ReactiveVar 0
  @delta = new ReactiveVar 0
  @rank = new ReactiveVar 0
  @speed = new ReactiveVar 0
  @subscribe 'getTiles'
  @subscribe 'getTileCounts'
  @autorun =>
    if @subscriptionsReady() and Counts.get('tileCount') is 0
      Meteor.call 'initTiles'
  window.addEventListener 'keydown', (e)->
    $(".row:nth-last-child(3)>.cell")[constants.keymap[e.which]].dispatchEvent new MouseEvent 'mousedown' if constants.keymap[e.which]?

Template.stage.helpers
  tiles: ->
    steps = Template.instance().steps.get()
    tiles = Tiles.find {},
      skip: steps
      limit: 5
      sort:
        c: 1
    checkDie=(du,idx)->
      return false unless du?
      return true for d in du when d.deadTile is idx
      false

    t=(du:tile.du, cols:(id:tile._id, idx: idx, die:checkDie(tile.du, idx), tile:tile.t isnt idx, valid: r is 0 for idx in [0..3]) for tile,r in tiles.fetch())
    t.reverse()
  isLastIdx: (idx)->
    idx is Tiles.findOne({},
      sort:
        idx: 1
    ).idx
  steps: ->
    t = Template.instance()
    steps = t.steps.get()
    if steps is 1
      t.prevTime = +new Date()
      Meteor.call 'getServerTime', (err, result)=>
        t.beginTime = result
    t.currentTime = +new Date() if t.prevTime > 0
      steps

  isReady: ->
    Template.instance().steps.get() > 0 and Meteor.userId()
  user: ->
    Meteor.user()
  delta: ->
    t = Template.instance()
    t.steps.get()
    delta = t.currentTime-t.prevTime
    t.prevTime = t.currentTime
    t.delta.set delta if delta > 0
    delta
  sDelta: ->
    t = Template.instance()
    delta = t.delta.get()
    t.sDelta = t.sDelta is 0 and delta or (t.sDelta>delta and delta) or t.sDelta
  rank: ->
    Template.instance().rank.get()
  speed: ->
    Template.instance().speed.get()
Template.stage.events
  'mousedown .cell.white, touchstart .cell.white': (e)->
    if @valid
      t = Template.instance()
      soundObject.die()
      lastOne = t.steps.get() + Session.get('bonus')
      showScoreModal e

      t.speed.set (1000 * lastOne / (t.currentTime - t.beginTime)).toFixed(2)
      Meteor.call 'recordLeaderboard', t.beginTime, lastOne, @id, @idx, (err, result)->
        unless err
          t.rank.set result.rank
          Session.set('bonus', 0)
    e.stopPropagation()
    e.preventDefault()
  'mousedown .cell.black, touchstart .cell.black': (e)->
    if @valid

      # Tap Effect
      tapEffect(e)

      steps = Template.instance().steps
      currentStep = steps.get()
      soundObject.beep currentStep+1
      Meteor.call 'initTiles' if addCondition currentStep, Counts.get 'tileCount'
      steps.set currentStep+1
    e.stopPropagation()
    e.preventDefault()

  'click button.close, touchend button.close': (e, t)->
    e.preventDefault()

    $('.modal').removeClass('modal-show')

    t.data.idHandle.set Random.id()
    t.steps.set 0

