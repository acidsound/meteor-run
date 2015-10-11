Template.main.onCreated ->
  @id = new ReactiveVar Random.id()
Template.main.helpers
  main: ->
    'stage'
  data: ->
    id: Template.instance().id.get()
    idHandle: Template.instance().id
