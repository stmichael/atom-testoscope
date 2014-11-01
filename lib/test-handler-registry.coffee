module.exports =
class TestHandlerRegistry

  constructor: ->
    @handlers = {}

  add: (name, handler) ->
    @handlers[name] = handler

  find: (name) ->
    @handlers[name]

  has: (name) ->
    @find(name) != undefined
