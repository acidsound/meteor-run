Template.splash.onCreated ->
  Session.set('easterCounter', 0)

Template.splash.events
  'click .splash-start, touchend .splash-start': (e) ->
    e.preventDefault()

    soundObject.initAudio()

    bonus = ~~(Session.get('easterCounter')/3) * 5

    Session.set('bonus', bonus)

    $('.splash-container').addClass('fade-out');
    $('.splash-container').one constants.transitionEnd, ->
      $(@).remove()

  'click .fixed-bottom': (e)->
    e.preventDefault()

    Session.set('easterCounter', Session.get('easterCounter') + 1)



