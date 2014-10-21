module.exports =
class TestHandlerRegistry
  constructor: ->
    @handlers = []

  add: (handler, fileTypes) ->
    if Object.prototype.toString.call(fileTypes) != '[object Array]'
      fileTypes = [fileTypes]
    for fileType in fileTypes
      @handlers.push
        matcher: fileType
        handler: handler

  findForFile: (filePath) ->
    for handlerItem in @handlers
      if filePath.match(handlerItem.matcher) != null
        return handlerItem.handler
    return null
