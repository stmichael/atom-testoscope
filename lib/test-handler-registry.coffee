module.exports =
class TestHandlerRegistry
  constructor: ->
    @handlers = []

  add: (handler, fileTypes) ->
    @_add(handler, fileTypes, Array.prototype.push)

  addBefore: (handler, fileTypes) ->
    @_add(handler, fileTypes, Array.prototype.unshift)

  _add: (handler, fileTypes, addFunction) ->
    if Object.prototype.toString.call(fileTypes) != '[object Array]'
      fileTypes = [fileTypes]
    for fileType in fileTypes
      addFunction.call @handlers,
        matcher: fileType
        handler: handler

  findForFile: (filePath) ->
    for handlerItem in @handlers
      if filePath.match(handlerItem.matcher) != null
        return handlerItem.handler
    return null
