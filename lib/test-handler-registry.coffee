module.exports =
class TestHandlerRegistry
  constructor: ->
    @handlers = []

  add: (handler, matchings) ->
    @_add(handler, matchings, Array.prototype.push)

  addBefore: (handler, matchings) ->
    @_add(handler, matchings, Array.prototype.unshift)

  _add: (handler, matchings, addFunction) ->
    if Object.prototype.toString.call(matchings) != '[object Array]'
      matchings = [matchings]
    for matching in matchings
      matchingFunction = if Object.prototype.toString.call(matching) == '[object RegExp]'
        ((matching) ->
          (path) ->
            path.match matching
        )(matching)
      else
        matching

      addFunction.call @handlers,
        matcher: matchingFunction
        handler: handler

  findForFile: (path) ->
    for handlerItem in @handlers
      if handlerItem.matcher(path)
        return handlerItem.handler
    return null
